#include "shell_app.hpp"
#include <cstdlib>
#include <gdk/gdkwayland.h>
#include <glibmm/main.h>
#include <iostream>
#include <memory>
#include <sys/inotify.h>

#include <cstdlib>
#include <getopt.h>
#include <iostream>

#include <unistd.h>

template<typename... Args>
void ignore(Args...)
{}

int ShellApp::on_command_line(
    const Glib::RefPtr<Gio::ApplicationCommandLine> & command_line,
    Glib::RefPtr<Gtk::Application> & app)
{
    int native_argc    = 0;
    char **native_argv = command_line->get_arguments(native_argc);

    args.clear();
    for (int i = 0; i < native_argc; ++i)
    {
        args.push_back(native_argv[i]);
    }

    g_strfreev(native_argv);

    app->activate();
    return EXIT_SUCCESS;
}

void ShellApp::on_activate()
{
    app->hold();

    auto display = Gdk::Display::get_default();
    if (config.enable_multi_monitors)
    {
        display->signal_monitor_added().connect_notify(
            [=] (const GMonitor & monitor) { this->add_monitor(monitor); });
        display->signal_monitor_removed().connect_notify(
            [=] (const GMonitor & monitor) { this->rem_monitor(monitor); });
    }

    // initial monitors
    int num_monitors = display->get_n_monitors();
    for (int i = 0; i < num_monitors; i++)
    {
        add_monitor(display->get_monitor(i));
        if (!config.enable_multi_monitors)
        {
            break;
        }
    }
}

void ShellApp::on_shutdown()
{
    rem_all_monitor();
}

void ShellApp::signal_add_output(WaylandOutput *output)
{
    handle_new_output(output);
}

void ShellApp::signal_rem_output(WaylandOutput *output)
{
    handle_output_removed(output);
}

void ShellApp::add_monitor(GMonitor monitor)
{
    monitors.push_back(std::make_unique<WaylandOutput>(monitor, this));
    signal_add_output(monitors.back().get());
}

void ShellApp::rem_monitor(GMonitor monitor)
{
    auto it = std::find_if(
        monitors.begin(), monitors.end(),
        [monitor] (const auto & output) { return output->monitor == monitor; });

    if (it != monitors.end())
    {
        signal_rem_output(it->get());
        monitors.erase(it, monitors.end());
    }
}

void ShellApp::rem_all_monitor()
{
    for (auto it = monitors.begin(); it != monitors.end();)
    {
        signal_rem_output(it->get());
        it = monitors.erase(it);
    }
}

static const char *get_version_string()
{
    return "1.0.0";
}

static void print_version_and_exit()
{
    std::cout << get_version_string() << std::endl;
    exit(0);
}

static void print_help()
{
    std::cout << "flgreet: " << get_version_string() << std::endl;
    std::cout << "Usage: flgreet [OPTION]...\n" << std::endl;
    std::cout << " -h,  --help              print this help" << std::endl;
    std::cout <<
        " -m,  --multi-monitors    (true/false) specify whether multi "
        "monitors support should be enabled or disabled " <<
        "(only takes effect when Layer Shell is enabled; enabled by default)" <<
        std::endl;
    std::cout << " -l,  --layer-shell       enable Layer Shell support" <<
        std::endl;
    std::cout << " -v,  --version           print version and exit" << std::endl;
    exit(0);
}

static bool parse_bool(const char *s, bool & out)
{
    if (!s)
    {
        return false;
    }

    std::string v(s);
    for (auto & c : v)
    {
        c = static_cast<char>(std::tolower(static_cast<unsigned char>(c)));
    }

    if ((v == "true") || (v == "1") || (v == "yes") || (v == "y"))
    {
        out = true;
        return true;
    }

    if ((v == "false") || (v == "0") || (v == "no") || (v == "n"))
    {
        out = false;
        return true;
    }

    return false;
}

void ShellApp::init_congfig(int argc, char **argv)
{
    const option opts[] = {{"help", no_argument, nullptr, 'h'},
        {"multi-monitors", required_argument, nullptr, 'm'},
        {"layer-shell", no_argument, nullptr, 'l'},
        {"version", no_argument, nullptr, 'v'},
        {nullptr, 0, nullptr, 0}};

    int opt;
    while ((opt = getopt_long(argc, argv, "hm:lv", opts, nullptr)) != -1)
    {
        switch (opt)
        {
          case 'h':
            print_help();
            break;

          case 'v':
            print_version_and_exit();
            break;

          case 'l':
            config.enable_layer_shell = true;
            break;

          case 'm':
        {
            bool parsed = false;
            bool b = false;
            if (!parse_bool(optarg, b))
            {
                std::cerr << "Invalid value for --multi-monitors: " << optarg <<
                    " (expected true/false)\n";
                print_help();
            }

            config.enable_multi_monitors = b;
            (void)parsed;
            break;
        }

          case '?':
          default:
            print_help();
        }
    }

    if (!config.enable_layer_shell)
    {
        config.enable_multi_monitors = false;
    }
}

ShellApp::ShellApp(int argc, char **argv) :
    app(Gtk::Application::create(argc, argv, "",
        Gio::APPLICATION_HANDLES_COMMAND_LINE))
{
    for (int i = 0; i < argc; ++i)
    {
        args.push_back(argv[i]);
    }

    init_congfig(argc, argv);

    app->signal_activate().connect_notify(
        sigc::mem_fun(this, &ShellApp::on_activate));

    app->signal_shutdown().connect_notify(
        sigc::mem_fun(this, &ShellApp::on_shutdown));

    // Activate app after parsing command line
    app->signal_command_line().connect_notify(
        [=] (const Glib::RefPtr<Gio::ApplicationCommandLine> & command_line)
    {
        on_command_line(command_line, app);
    });
}

ShellApp::~ShellApp()
{}

std::unique_ptr<ShellApp> ShellApp::instance;
ShellApp& ShellApp::get()
{
    return *instance;
}

void ShellApp::run()
{
    app->run();
}

/* -------------------------- WaylandOutput --------------------------------- */
WaylandOutput::WaylandOutput(const GMonitor & monitor, void *data)
{
    this->monitor = monitor;
    this->wo = gdk_wayland_monitor_get_wl_output(monitor->gobj());
}

WaylandOutput::~WaylandOutput()
{}
