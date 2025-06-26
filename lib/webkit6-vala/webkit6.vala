using Gtk;
using WebKit;
using GLib;
using Notify;

public class App: GLib.Object {
    public Gtk.Application app;
    public WebKit.WebView webview;
    public Gtk.Window win;
    private string home_url;
    private string title;
    private int notice_n = 0;

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
            stderr.puts(e.message);
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
        //stdout.printf("user-agent:%s\n",settings.user_agent);
        settings.user_agent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/60.5 Safari/605.1.15 Chrome/120.0.0.0 Safari/537.36";
        settings.javascript_can_open_windows_automatically = true;
        settings.javascript_can_access_clipboard = true;
        settings.auto_load_images = true;
        settings.enable_javascript = true;
        settings.enable_javascript_markup = true;
        settings.enable_tabs_to_links = true;
        this.webview.set_child_visible(true);
        this.webview.network_session.download_started.connect((download)=>{
            download.decide_destination.connect((dst)=>{
                var dir1 = GLib.Environment.get_user_special_dir(GLib.UserDirectory.DOWNLOAD);
                //var f = File.new_for_path(Path.build_filename(dir1, dst ));
                
                var fname = dst;
                var n = 1;
                var name = fname;
                while (true) {
                    var f = File.new_for_path(Path.build_filename(dir1, name ));
                    if ( f.query_exists(null) ){
                        name = @"$(n)-$(fname)";
                        n++;
                        continue;
                    }else {
                        download.set_destination( Path.build_filename(dir1, name ) );
                        break;
                    }
                    
                }
                
                var dst_name = Path.build_filename(dir1, name );
                var notice = new Notify.Notification(@"Save: $(dst_name)", null, null);

                // stdout.printf("%s\n", @"Save: $(dst_name)");
                try{
                    notice.show();
                }
                catch(Error e){
                    stderr.puts(e.message);
                }
                
                this.notice_n++;
                
                return true;
            });
        });
        //  this.webview.network_session.download_started.connect((download)=>{
        //      download.set_allow_overwrite(false);
        //      download.created_destination.connect((dst)=>{
        //          var dir1 = Path.get_dirname(dst);
                
        //          var fname = Path.get_basename(dst);
        //          var n = 1;
        //          var name = fname;
        //          while (true) {
        //              var f = File.new_for_path(Path.build_filename(dir1, name ));
        //              if ( f.query_exists(null) ){
        //                  name = @"$(n)-$(fname)";
        //                  n++;
        //                  continue;
        //              }else {
        //                  download.set_destination( Path.build_filename(dir1, name ) );
        //                  break;
        //              }
                    
        //          }
                
        //          var dst_name = Path.build_filename(dir1, name );
        //          var notice = new GLib.Notification("Download");
        //          notice.set_body( @"Save: $(dst_name)" );
        //          stdout.printf("%s\n", @"Save: $(dst_name)");
        //          this.app.send_notification(@"app.notice.$(this.notice_n)", notice);
        //          this.notice_n++;
        //      });
            
        //  }
        //  );

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
