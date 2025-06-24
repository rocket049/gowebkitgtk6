#include "glib.h"
#include "webkit6go.h"

struct user_data_cb {
    const gchar *title;
    const gchar *start;
    const gchar *patten;
};

extern void WriteFolderPath(char *);
extern void WriteFilePath(char *);
extern void WriteSavePath(char *);

static void save_callback(GObject *src, GAsyncResult* _res_, gpointer user_data){
	char* res = (char*)app_file_save_dialog_finish( _res_);
	WriteSavePath(res);
}
static void folder_callback(GObject *src, GAsyncResult* _res_, gpointer user_data){
	char* res = (char*)app_folder_select_dialog_finish( _res_);
	WriteFolderPath(res);
}
static void file_callback(GObject *src, GAsyncResult* _res_, gpointer user_data){
	char* res = (char*)app_file_select_dialog_finish(_res_);
	WriteFilePath(res);
}

static void wrap_open_file_dialog_cb( struct user_data_cb *user_data ) {
    app_file_select_dialog (user_data->title,
                             user_data->patten,
                             user_data->start,
                             file_callback,
                             NULL);
}

static void wrap_save_file_dialog_cb( struct user_data_cb *user_data ) {
    app_file_save_dialog(user_data->title,
                        user_data->start,
                        save_callback,
                        NULL);
}

static void wrap_select_folder_dialog_cb( struct user_data_cb *user_data ) {
    app_folder_select_dialog(user_data->title,
                            user_data->start,
                            folder_callback,
                            NULL);
}

void file_select_dialog(const gchar* title,
                             const gchar* patten,
                             const gchar* start)
{
    struct user_data_cb *data = g_malloc(sizeof(struct user_data_cb));
    data->title = title;
    data->patten = patten;
    data->start = start;
	g_idle_add_full( G_PRIORITY_DEFAULT_IDLE, (GSourceFunc)wrap_open_file_dialog_cb, (void*)data, g_free );
}

void folder_select_dialog (const gchar* title,
                               const gchar* start)
{
    struct user_data_cb *data = g_malloc(sizeof(struct user_data_cb));
    data->title = title;
    data->patten = NULL;
    data->start = start;
    g_idle_add_full( G_PRIORITY_DEFAULT_IDLE, (GSourceFunc)wrap_select_folder_dialog_cb,  (void*)data, g_free );
}

void file_save_dialog (const gchar* title,
                               const gchar* start)
{
    struct user_data_cb *data = g_malloc(sizeof(struct user_data_cb));
    data->title = title;
    data->patten = NULL;
    data->start = start;
    g_idle_add_full( G_PRIORITY_DEFAULT_IDLE, (GSourceFunc)wrap_save_file_dialog_cb,  (void*)data, g_free );
}