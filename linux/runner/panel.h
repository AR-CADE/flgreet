#ifndef PANEL_H
#define PANEL_H

#include <gtkmm/window.h>
#include <memory>

#include "shell_app.h"
#include <map>

class PanelApp;

class FlutterPanel {
public:
  FlutterPanel(WaylandOutput *output, PanelApp *panel);

  wl_surface *get_wl_surface();
  Gtk::Window &get_window();
  void on_delete();

private:
  class impl;
  std::unique_ptr<impl> pimpl;
};

class PanelApp : public ShellApp {
public:
  FlutterPanel *panel_for_wl_output(const wl_output *output);
  static PanelApp &get();

  /* Starts the program. get() is valid afterward the first (and the only)
   * call to create() */
  static void create(int argc, char **argv);
  ~PanelApp();

  void handle_new_output(WaylandOutput *output) override;
  void handle_output_removed(WaylandOutput *output) override;

private:
  PanelApp(int argc, char **argv);

  class impl;
  std::unique_ptr<impl> priv;
};
#endif /* end of include guard: PANEL_H */