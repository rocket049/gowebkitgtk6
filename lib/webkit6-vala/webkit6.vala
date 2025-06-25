using Gtk;
using WebKit;
using GLib;

public class App: GLib.Object {
    public Gtk.Application app;
    public WebKit.WebView webview;
    public Gtk.Window win;
    private string home_url;
    private string title;

    public void create(string id, string title, string uri) {
        this.title = title;
        Gtk.init();
        this.app = new Gtk.Application(id, GLib.ApplicationFlags.DEFAULT_FLAGS);
        this.app.activate.connect((app)=>{
            //stdout.puts("on activate\n");
            this.on_app_activate(this.app, uri);
        });
    }

    public int run() {
        return this.app.run(null);
    }

    public static async string? file_save_dialog(string title, string? start){
        var dlg = new Gtk.FileDialog();
        
        dlg.set_modal(true);
        dlg.set_title(title);
        
        if( start != null ){
            var folder= GLib.File.new_for_path(start);
            dlg.set_initial_folder(folder);
        }
        try{
            var res = yield dlg.save(App.application.win, null);
            return res.get_path();
        }catch (GLib.Error e) {
            stderr.puts(e.message);
            return null;
        }
        
    }

    public static async string? file_select_dialog(string title, string? pattern, string? start){
        var dlg = new Gtk.FileDialog();
        
        dlg.set_modal(true);
        dlg.set_title(title);
        if( pattern != null ) {
            var filter= new Gtk.FileFilter();
            filter.add_pattern(pattern);
            dlg.set_default_filter(filter);
        }
        if( start != null ){
            var folder= GLib.File.new_for_path(start);
            dlg.set_initial_folder(folder);
        }
        try{
            var res = yield dlg.open(App.application.win, null);
            return res.get_path();
        }catch (GLib.Error e) {
            stderr.puts(e.message);
            return null;
        }
        
    }
    
    public static async string? folder_select_dialog(string title,  string? start){
            var dlg = new Gtk.FileDialog();
        
            dlg.set_modal(true);
            dlg.set_title(title);

            if( start != null ){
                var folder= GLib.File.new_for_path(start);
                dlg.set_initial_folder(folder);
            }
            try {
                var res = yield dlg.select_folder(App.application.win, null);
                return res.get_path();
            }
            catch (GLib.Error e ) {
                stderr.puts(e.message);
                return null;
            }

    }

    private void on_app_activate(Gtk.Application app, string uri) {
        this.home_url = uri;
        var win = new  Gtk.Window();
        win.set_title(this.title);
        this.app.add_window(win);
        this.webview = new WebKit.WebView();
        win.set_child(this.webview);

        win.close_request.connect(()=>{
            this.app.quit();
            return true;
        });

        this.webview.load_uri(uri);

        this.webview.context_menu.connect(( menu)=>{
            this.modify_menu(menu);
            return false;
        });

        var settings = this.webview.get_settings();
        settings.set("enable-developer_extras",true,null);

        win.present();
        this.win=win;
    }

    private void modify_menu( WebKit.ContextMenu menu ){
        var act1 = new GLib.SimpleAction("go home", null);
        act1.activate.connect(()=>{
            this.webview.load_uri(this.home_url);
        });
        var item = new WebKit.ContextMenuItem.from_gaction(act1 as GLib.Action, "go home", null);
        menu.append(item);
    }
    public static App application;
    public static void create_app(string id, string title, string url){
        App.application = new App();
        App.application.create(id,title,url);
    }
    public static int run_app() {
        return application.run();
    }
    public static void quit(){
        App.application.app.quit();
    }
    public static Gtk.Application get_application() {
        return application.app;
    }
    public static Gtk.Window get_window() {
        return application.win;
    }
    public static WebKit.WebView get_webview() {
        return application.webview;
    }
    public static void resize(int w, int h) {
        Idle.add(
            ()=>{
                application.win.set_size_request(w, h);
                return true;
            }, 
            GLib.Priority.DEFAULT_IDLE);
        
    }
    public static void show_inspector(){
        Idle.add(()=>{
            var inspector= application.webview.get_inspector();
            inspector.show();
            return true;
        },
        GLib.Priority.DEFAULT_IDLE);
    }
}
