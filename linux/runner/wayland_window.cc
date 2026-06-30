#include "wayland_window.h"

#include "shell_app.h"
#include <gdk/gdkwayland.h>
#include <gtk-layer-shell/gtk-layer-shell.h>

#include <assert.h>
#include <glibmm.h>

#if 0
void WaylandWindow::set_fullscreen_on_monitor(GtkWindow *window,
                                              GdkMonitor *monitor) {
  GdkDisplay *display = gdk_monitor_get_display(monitor);

  int n = gdk_display_get_n_monitors(display);
  int idx = -1;
  for (int i = 0; i < n; i++) {
    GdkMonitor *m = gdk_display_get_monitor(display, i);
    if (m == monitor) {
      idx = i;
      break;
    }
  }

  if (idx < 0) {
    return;
  }

  GdkRectangle geometry;
  gdk_monitor_get_geometry(monitor, &geometry);

  gtk_window_move(window, geometry.x, geometry.y);

  GdkScreen *screen = gtk_window_get_screen(window);

  if (screen) {
    gtk_window_fullscreen_on_monitor(window, screen, idx);
  }
}
#endif

WaylandWindow::WaylandWindow(WaylandOutput *output, AppConfig *config,
                             bool has_exclusive_zone) {
  this->output = output;
  this->set_decorated(false);

  if (config->enable_layer_shell) {
    this->set_resizable(false);

    gtk_layer_init_for_window(this->gobj());
    gtk_layer_set_monitor(this->gobj(), output->monitor->gobj());
    gtk_layer_set_namespace(this->gobj(), "flgreet");
    set_layer();

    gtk_layer_auto_exclusive_zone_enable (this->gobj());
    gtk_layer_set_keyboard_mode (this->gobj(), GTK_LAYER_SHELL_KEYBOARD_MODE_EXCLUSIVE);


    gtk_layer_set_anchor(this->gobj(), GTK_LAYER_SHELL_EDGE_TOP, true);
    gtk_layer_set_anchor(this->gobj(), GTK_LAYER_SHELL_EDGE_RIGHT, true);
    gtk_layer_set_anchor(this->gobj(), GTK_LAYER_SHELL_EDGE_BOTTOM, true);
    gtk_layer_set_anchor(this->gobj(), GTK_LAYER_SHELL_EDGE_LEFT, true);

  } else {
    this->set_resizable(true);
#if 0
  set_fullscreen_on_monitor(this->gobj(), output->monitor->gobj());
#endif
  }
}

WaylandWindow::~WaylandWindow() {}

wl_surface *WaylandWindow::get_wl_surface() const {
  auto win = this->get_window();
  if (!win) {
    return nullptr;
  }
  return gdk_wayland_window_get_wl_surface(
      const_cast<GdkWindow *>(win->gobj()));
}

void WaylandWindow::set_layer() {
  if (panel_layer == "overlay")
    gtk_layer_set_layer(this->gobj(), GTK_LAYER_SHELL_LAYER_OVERLAY);
  if (panel_layer == "top")
    gtk_layer_set_layer(this->gobj(), GTK_LAYER_SHELL_LAYER_TOP);
  if (panel_layer == "bottom")
    gtk_layer_set_layer(this->gobj(), GTK_LAYER_SHELL_LAYER_BOTTOM);
  if (panel_layer == "background")
    gtk_layer_set_layer(this->gobj(), GTK_LAYER_SHELL_LAYER_BACKGROUND);
}

