#ifndef WAYLAND_WINDOW_H
#define WAYLAND_WINDOW_H

#include <gdk/gdkwayland.h>
#include <gtkmm/window.h>

struct WaylandOutput;
struct AppConfig;
// #define ENABLE_LAYER_SHELL

class WaylandWindow : public Gtk::Window {
public:
  WaylandWindow(WaylandOutput *output, AppConfig *config,
                bool has_exclusive_zone = true);

  ~WaylandWindow();
  wl_surface *get_wl_surface() const;

  /** When auto exclusive zone is set, the window will adjust its exclusive
   * zone based on the window size.
   *
   * Note that autohide margin isn't taken into account. */
  void set_auto_exclusive_zone(bool has_zone = false);

private:
  WaylandOutput *output;
#if 1
  void set_fullscreen_on_monitor(GtkWindow *window, GdkMonitor *monitor);
#endif

  std::string panel_layer = "top";
  void set_layer();
  int last_zone = 0;
};

#endif /* end of include guard: WAYLAND_WINDOW_H */
