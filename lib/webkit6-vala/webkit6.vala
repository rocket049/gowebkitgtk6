using Gtk;
using WebKit;
using GLib;
using Notify;
using Posix;

public class App: GLib.Object {
    public Gtk.Application app;
    public WebKit.WebView webview;
    public Gtk.Window win;
    private string home_url;
    private string title;
    private bool auto_name = false;
    public string save_path = "";
    public void create(string id, string title, string uri) {
        this.title = title;
        Gtk.init();
        this.app = new Gtk.Application(id, GLib.ApplicationFlags.DEFAULT_FLAGS);
        Notify.init(id);
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
            var f1= GLib.File.new_for_path(start);
            dlg.set_initial_file(f1);
        }
        try{
            var res = yield dlg.save(App.application.win, null);
            return res.get_path();
        }catch (GLib.Error e) {
            GLib.stderr.puts(e.message);
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
            GLib.stderr.puts(e.message);
            return null;
        }
        
    }

    public static async string? multi_file_select(string title, string? pattern, string? start){
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
            var res = yield dlg.open_multiple(App.application.win, null);
            string[] ret = new string[res.get_n_items()];
            for(var i=0;i<res.get_n_items();i++) {
                var f =(GLib.File)res.get_item(i);
                ret[i] = f.get_path();
            }
            var result = string.joinv(":", ret);
            //App.application.callback(result);
            return result;
        }catch (GLib.Error e) {
            GLib.stderr.puts(e.message);
            return null;
        }
    }

    public static async string? multi_folder_select(string title, string? start){
        var dlg = new Gtk.FileDialog();
        
        dlg.set_modal(true);
        dlg.set_title(title);

        if( start != null ){
            var folder= GLib.File.new_for_path(start);
            dlg.set_initial_folder(folder);
        }
        try{
            var res = yield dlg.select_multiple_folders(App.application.win, null);
            string[] ret = new string[res.get_n_items()];
            for(var i=0;i<res.get_n_items();i++) {
                var f =(GLib.File)res.get_item(i);
                ret[i] = f.get_path();
            }
            var result = string.joinv(":", ret);

            return result;
        }catch (GLib.Error e) {
            GLib.stderr.puts(e.message);
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
                GLib.stderr.puts(e.message);
                return null;
            }

    }
    private async bool select_file_and_save( string name ) {
        var start = name;
        //GLib.stdout.puts(start);

        if ( this.save_path.length > 0 ) {
            start = Path.build_filename(this.save_path, Path.get_basename(start));
        } else {
            start = Path.build_filename(GLib.Environment.get_home_dir(), Path.get_basename(start));
        }
        
        var p = yield App.file_save_dialog("保存文件(Save file)", start);
        if (p!=null) {
            var f1 = GLib.File.new_for_path(name);
            var f2 = GLib.File.new_for_path(p);
            
            try {
                var ret = f1.copy(f2, GLib.FileCopyFlags.OVERWRITE, null, null );
                Posix.unlink(name);
                this.save_path = Path.get_dirname( p );
                //GLib.stdout.puts(p);
                return ret;
            }
            catch (Error e) {
                GLib.stderr.puts(e.message);
            }
        }
        return true;
    }
    public static void set_auto_save(int m) {
        bool mode = (m==0)?false:true;
        App.application.auto_name = mode;
    }

    public static void set_save_path(string s) {
        App.application.save_path = s;
    }

    private void on_app_activate(Gtk.Application app, string uri) {
        this.home_url = uri;
        var win = new  Gtk.Window();
        win.set_title(this.title);
        this.app.add_window(win);
        this.webview = new WebKit.WebView();
        win.set_child(this.webview);
        var settings = this.webview.get_settings();
        
        settings.allow_file_access_from_file_urls = true;
        settings.allow_modal_dialogs = true;
        settings.allow_top_navigation_to_data_urls = true;
        settings.allow_universal_access_from_file_urls = true;
        settings.enable_webgl = true;
        settings.enable_webrtc = true;
        settings.enable_html5_database = true;
        settings.enable_html5_local_storage = true;
        settings.enable_encrypted_media = true;
        settings.enable_media = true;
        settings.enable_media_capabilities = true;
        settings.enable_media_stream = true;
        settings.enable_mediasource = true;
        settings.enable_write_console_messages_to_stdout = true;
        settings.javascript_can_open_windows_automatically = true;
        settings.javascript_can_access_clipboard = true;
        settings.auto_load_images = true;
        settings.enable_javascript = true;
        settings.enable_javascript_markup = true;
        settings.enable_tabs_to_links = true;
        this.webview.set_child_visible(true);
        this.webview.network_session.download_started.connect((download)=>{
            download.finished.connect(()=>{
                if ( !auto_name ){
                    select_file_and_save(download.get_destination());
                }
                    
            });
            download.decide_destination.connect((dst)=>{
                var dir1 = this.save_path;

                if ( !auto_name ) {
                    dir1 = Path.build_filename(GLib.Environment.get_tmp_dir(), "webkit6go");
                    Posix.mkdir(dir1, 0755);
                } else {
                    if ( dir1.length == 0 ) {
                        dir1 = GLib.Environment.get_user_special_dir(GLib.UserDirectory.DOWNLOAD);
                    }
                }

                var fname = dst;

                var name = fname;
                
                if (  !auto_name ) {
                    var f = File.new_for_path(Path.build_filename(dir1, name ));
                    if (f.query_exists(null))
                        Posix.unlink( Path.build_filename(dir1, name ) );
                }
                else {
                    var n = 1;
                    while (true) {
                        var f2 = File.new_for_path(Path.build_filename(dir1, name ));
                        if ( f2.query_exists(null) ){
                            var v1 = fname.split(".", -1);
                            if (v1.length==1)
                                name = @"$(n)-$(fname)";
                            else {
                                v1[v1.length-2] = @"$(v1[v1.length-2])-$(n)";
                                name = string.joinv(".", v1);
                            }
                            n++;
                            continue;
                        }else {
                            break;
                        }
                    }
                }
                
                var dst_name = Path.build_filename(dir1, name );
                download.set_destination( dst_name );
                if (auto_name) {
                    var notice = new Notify.Notification(@"Save: $(dst_name)", null, null);

                    // stdout.printf("%s\n", @"Save: $(dst_name)");
                    try{
                        notice.show();
                    }
                    catch(Error e){
                        GLib.stderr.puts(e.message);
                    }
                }
                
                return true;
            });
        });

        win.close_request.connect(()=>{
            this.app.quit();
            return true;
        });
        this.webview.load_failed.connect((e)=>{
            this.webview.load_uri(uri);
            return true;
        });
        this.webview.load_uri(uri);

        this.webview.context_menu.connect(( menu)=>{
            this.modify_menu(menu);
            return false;
        });

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
                return false;
            }, 
            GLib.Priority.DEFAULT_IDLE);
        
    }
    public static void show_inspector(){
        Idle.add(()=>{
            var inspector= application.webview.get_inspector();
            inspector.closed.connect(()=>{
                inspector.close();
            });
            inspector.show();
            return false;
        },
        GLib.Priority.DEFAULT_IDLE);
    }    
}
