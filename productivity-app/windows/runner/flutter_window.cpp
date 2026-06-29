#include "flutter_window.h"

#include <optional>
#include <propkey.h>
#include <propvarutil.h>
#include <shobjidl_core.h>
#include <string>

#include "flutter/generated_plugin_registrant.h"
#include "resource.h"

namespace {

void ApplyTaskbarBranding(HWND hwnd) {
  IPropertyStore* property_store = nullptr;
  if (FAILED(SHGetPropertyStoreForWindow(hwnd, IID_PPV_ARGS(&property_store))) ||
      property_store == nullptr) {
    return;
  }

  wchar_t exe_path[MAX_PATH];
  DWORD path_length = GetModuleFileName(nullptr, exe_path, MAX_PATH);
  std::wstring relaunch_icon = path_length > 0
      ? std::wstring(exe_path) + L",0"
      : L"CUBBY.exe,0";

  PROPVARIANT app_id;
  PropVariantInit(&app_id);
  if (SUCCEEDED(InitPropVariantFromString(L"CUBBY.Desktop", &app_id))) {
    property_store->SetValue(PKEY_AppUserModel_ID, app_id);
  }
  PropVariantClear(&app_id);

  PROPVARIANT display_name;
  PropVariantInit(&display_name);
  if (SUCCEEDED(InitPropVariantFromString(L"CUBBY", &display_name))) {
    property_store->SetValue(PKEY_AppUserModel_RelaunchDisplayNameResource,
                             display_name);
  }
  PropVariantClear(&display_name);

  PROPVARIANT icon_resource;
  PropVariantInit(&icon_resource);
  if (SUCCEEDED(InitPropVariantFromString(relaunch_icon.c_str(), &icon_resource))) {
    property_store->SetValue(PKEY_AppUserModel_RelaunchIconResource,
                             icon_resource);
  }
  PropVariantClear(&icon_resource);

  property_store->Commit();
  property_store->Release();
}

}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  HICON app_icon = static_cast<HICON>(
      LoadImage(GetModuleHandle(nullptr), MAKEINTRESOURCE(IDI_APP_ICON),
                IMAGE_ICON, 0, 0, LR_DEFAULTSIZE));
  if (app_icon != nullptr) {
    SendMessage(GetHandle(), WM_SETICON, ICON_BIG,
                reinterpret_cast<LPARAM>(app_icon));
    SendMessage(GetHandle(), WM_SETICON, ICON_SMALL,
                reinterpret_cast<LPARAM>(app_icon));
    SendMessage(GetHandle(), WM_SETICON, ICON_SMALL2,
                reinterpret_cast<LPARAM>(app_icon));
  }
  ApplyTaskbarBranding(GetHandle());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
