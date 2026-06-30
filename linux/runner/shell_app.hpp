#ifndef SHELL_APP_H
#define SHELL_APP_H

#include <memory>
#include <string>

#include <gdk/gdkwayland.h>
#include <gdkmm/monitor.h>
#include <gtkmm/application.h>
#include <vector>

using GMonitor = Glib::RefPtr<Gdk::Monitor>;
/**
 * Represents a single output
 */
struct WaylandOutput
{
    GMonitor monitor;
    wl_output *wo;

    WaylandOutput(const GMonitor & monitor, void *data);
    ~WaylandOutput();
};

struct output;

struct AppConfig
{
    bool enable_multi_monitors = true;
    bool enable_layer_shell    = false;
};

/**
 * A basic shell application.
 *
 * It is suitable for applications that need to show one or more windows
 * per monitor.
 */
class ShellApp
{
  private:
    std::vector<std::unique_ptr<WaylandOutput>> monitors;
    int on_command_line(
        const Glib::RefPtr<Gio::ApplicationCommandLine> & command_line,
        Glib::RefPtr<Gtk::Application> & app);
    void init_congfig(int argc, char **argv);

  protected:
    /** This should be initialized by the subclass in each program which uses
     * shell-app */
    static std::unique_ptr<ShellApp> instance;

    Glib::RefPtr<Gtk::Application> app;

    virtual void add_monitor(GMonitor monitor);
    virtual void rem_monitor(GMonitor monitor);

    /* The following functions can be overridden in the shell implementation to
     * handle the events */
    virtual void on_activate();
    virtual void on_shutdown();

    virtual void handle_new_output(WaylandOutput *output)
    {}
    virtual void handle_output_removed(WaylandOutput *output)
    {}

  public:
    ShellApp(int argc, char **argv);

    virtual ~ShellApp();

    std::vector<std::string> args;

    AppConfig config = {};

    void rem_all_monitor();

    virtual void run();

    /**
     * ShellApp is a singleton class.
     * Using this function, any part of the application can get access to the
     * shell app.
     */
    static ShellApp & get();

    virtual void signal_add_output(WaylandOutput *output);
    virtual void signal_rem_output(WaylandOutput *output);
};

#endif /* end of include guard: SHELL_APP_H */
