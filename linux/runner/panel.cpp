#include <cstddef>
#include <cstdlib>
#include <gdk/gdkwayland.h>
#include <glibmm/main.h>
#include <gtk-layer-shell.h>
#include <gtkmm/application.h>
#include <gtkmm/cssprovider.h>
#include <gtkmm/headerbar.h>
#include <gtkmm/hvbox.h>
#include <gtkmm/window.h>

#include "panel.hpp"
#include "wayland_window.hpp"

#include <string>

#include <flutter_linux/flutter_linux.h>

#include "flutter/generated_plugin_registrant.h"

#ifdef ENABLE_CSS
Glib::RefPtr<Gtk::CssProvider> load_css_from_path(std::string path) {
  try {
    auto css = Gtk::CssProvider::create();
    css->load_from_path(path);
    return css;
  } catch (Glib::Error &err) {
    std::cerr << "Failed to load CSS: " << err.what() << std::endl;
    return {};
  } catch (...) {
    std::cerr << "Failed to load CSS at: " << path << std::endl;
    return {};
  }
}
#endif

class FlutterPanel::impl {
  std::unique_ptr<WaylandWindow> window;
  WaylandOutput *output;
  FlView *view;

#ifdef ENABLE_CSS
  std::string css_path = "YOUR_PATH";
#endif
  std::string bg_color = "gtk_headerbar";

  std::vector<std::string> args;
  std::vector<char *> dart_argv;
  PanelApp *panel = nullptr;

  void create_window() {
    window = std::make_unique<WaylandWindow>(output, &panel->config, false);

    GdkRectangle geometry;
    gdk_monitor_get_geometry(output->monitor->gobj(), &geometry);

    window->set_default_size(geometry.width, geometry.height);
    window->set_title("flgreet");

    on_window_color_updated(); // set initial color

#ifdef ENABLE_CSS
    if (css_path != "") {
      auto css = load_css_from_path(css_path);
      if (css) {
        auto screen = Gdk::Screen::get_default();
        auto style_context = Gtk::StyleContext::create();
        style_context->add_provider_for_screen(
            screen, css, GTK_STYLE_PROVIDER_PRIORITY_USER);
      }
    }
#endif

    init_widget();

    window->signal_delete_event().connect(
        sigc::mem_fun(this, &FlutterPanel::impl::on_delete_event));
  }

  bool on_delete_event(GdkEventAny *ev) {

#ifdef DEBUG
    panel->rem_all_monitor();
    return false;
#endif
    /* We ignore close events, because the panel's lifetime is bound to
     * the lifetime of the output */
    return true;
  }

  // Called when first Flutter frame received.
  static void first_frame_cb(void *data, FlView *view) {
    gtk_widget_show(gtk_widget_get_toplevel(GTK_WIDGET(view)));
  }

  void init_widget() {
    g_autoptr(FlDartProject) project = fl_dart_project_new();
    dart_argv.clear();
    if (args.size() > 1) {
      for (size_t i = 1; i < args.size(); ++i) {
        dart_argv.push_back(const_cast<char *>(args[i].c_str()));
      }
    }
    dart_argv.push_back(nullptr);

    fl_dart_project_set_dart_entrypoint_arguments(project, dart_argv.data());

    view = fl_view_new(project);
    gtk_widget_show(GTK_WIDGET(view));
    gtk_container_add(GTK_CONTAINER(window->gobj()), GTK_WIDGET(view));

    // Show the window immediately for faster visual feedback
    gtk_widget_show(GTK_WIDGET(window->gobj()));
    gtk_widget_realize(GTK_WIDGET(view));

    fl_register_plugins(FL_PLUGIN_REGISTRY(view));

    gtk_widget_grab_focus(GTK_WIDGET(view));
  }

  void on_window_color_updated() {
    if (bg_color == "gtk_default")
      return window->unset_background_color();

    Gdk::RGBA rgba;
    if (bg_color == "gtk_headerbar") {
      Gtk::HeaderBar headerbar;
      rgba = headerbar.get_style_context()->get_background_color();
    } else {
      return;
      // auto color = wf::option_type::from_string<wf::color_t> (
      //     ((wf::option_sptr_t<std::string>)bg_color)->get_value_str());
      // if (!color) {
      //     std::cerr << "Invalid panel background color in"
      //         " config file" << std::endl;
      //     return;
      // }

      // rgba.set_red(color.value().r);
      // rgba.set_green(color.value().g);
      // rgba.set_blue(color.value().b);
      // rgba.set_alpha(color.value().a);
    }

    window->override_background_color(rgba);
  }

public:
  impl(WaylandOutput *output, PanelApp *panel) {
    this->output = output;
    this->args = panel->args;
    this->panel = panel;
    create_window();
  }

  ~impl() {}

  void on_delete() {
    gtk_widget_destroy(GTK_WIDGET(window->gobj()));
  }

  wl_surface *get_wl_surface() { return window->get_wl_surface(); }

  Gtk::Window &get_window() { return *window; }
};

FlutterPanel::FlutterPanel(WaylandOutput *output, PanelApp *panel)
    : pimpl(new impl(output, panel)) {}
wl_surface *FlutterPanel::get_wl_surface() { return pimpl->get_wl_surface(); }
Gtk::Window &FlutterPanel::get_window() { return pimpl->get_window(); }
void FlutterPanel::on_delete() { return pimpl->on_delete(); }

class PanelApp::impl {
public:
  std::map<WaylandOutput *, std::unique_ptr<FlutterPanel>> panels;
};

void PanelApp::handle_new_output(WaylandOutput *output) {
  priv->panels[output] =
      std::unique_ptr<FlutterPanel>(new FlutterPanel(output, this));
}

FlutterPanel *PanelApp::panel_for_wl_output(const wl_output *output) {
  for (auto &p : priv->panels) {
    if (p.first->wo == output)
      return p.second.get();
  }

  return nullptr;
}

void PanelApp::handle_output_removed(WaylandOutput *output) {
  FlutterPanel *p = panel_for_wl_output(output->wo);
  if (p) {
    p->on_delete();
  }
  priv->panels.erase(output);
}

PanelApp &PanelApp::get() {
  if (!instance)
    throw std::logic_error("Calling PanelApp::get() before starting app!");
  return dynamic_cast<PanelApp &>(*instance.get());
}

void PanelApp::create(int argc, char **argv) {
  if (instance)
    throw std::logic_error("Running PanelApp twice!");

  instance = std::unique_ptr<ShellApp>(new PanelApp{argc, argv});
  instance->run();
}

PanelApp::~PanelApp() = default;
PanelApp::PanelApp(int argc, char **argv)
    : ShellApp(argc, argv), priv(new impl()) {}
