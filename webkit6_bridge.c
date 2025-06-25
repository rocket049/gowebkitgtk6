#include "glib.h"
#include "webkit6go.h"
#include <stdlib.h>

struct user_data_cb {
    const gchar *title;
    const gchar *start;
    const gchar *patten;
};

extern void WriteFolderPath(char *);
extern void WriteFilePath(char *);
extern void WriteSavePath(char *);
extern void WriteMultiFile(char *);
extern void WriteMultiFolder(char *);

void free_user_data(struct user_data_cb *p){
    if (p==NULL) return;
    if (p->title != NULL) free( (void*) p->title );
    if (p->start != NULL ) free( (void*) p->start );
    if (p->patten != NULL) free( (void*) p->patten );
    g_free( (void*)p );
}

static void save_callback(GObject *src, GAsyncResult* _res_, gpointer user_data){
	char* res = (char*)app_file_save_dialog_finish( _res_);
	WriteSavePath(res);
    free((void*)res);
}
static void folder_callback(GObject *src, GAsyncResult* _res_, gpointer user_data){
	char* res = (char*)app_folder_select_dialog_finish( _res_);
	WriteFolderPath(res);
    free((void*)res);
}
static void file_callback(GObject *src, GAsyncResult* _res_, gpointer user_data){
	char* res = (char*)app_file_select_dialog_finish(_res_);
	WriteFilePath(res);
    free((void*)res);
}

static void multi_file_callback(GObject *src, GAsyncResult* _res_, gpointer user_data){
	char* res = (char*)app_multi_file_select_finish(_res_);
	WriteMultiFile(res);
    free((void*)res);
}

static void multi_folder_callback(GObject *src, GAsyncResult* _res_, gpointer user_data){
	char* res = (char*)app_multi_folder_select_finish(_res_);
	WriteMultiFolder(res);
    free((void*)res);
}

static void wrap_open_file_dialog_cb( struct user_data_cb *user_data ) {
    app_file_select_dialog (user_data->title,
                             user_data->patten,
                             user_data->start,
                             file_callback,
                             NULL);
}

static void wrap_multi_file_select_cb( struct user_data_cb *user_data ) {
    app_multi_file_select (user_data->title,
                             user_data->patten,
                             user_data->start,
                             multi_file_callback,
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

static void wrap_multi_folder_select_cb( struct user_data_cb *user_data ) {
    app_multi_folder_select(user_data->title,
                            user_data->start,
                            multi_folder_callback,
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
	g_idle_add_full( G_PRIORITY_DEFAULT_IDLE, (GSourceFunc)wrap_open_file_dialog_cb, (void*)data, (GDestroyNotify)free_user_data );
}

void multi_file_select(const gchar* title,
                             const gchar* patten,
                             const gchar* start)
{
    struct user_data_cb *data = g_malloc(sizeof(struct user_data_cb));
    data->title = title;
    data->patten = patten;
    data->start = start;
	g_idle_add_full( G_PRIORITY_DEFAULT_IDLE, (GSourceFunc)wrap_multi_file_select_cb, (void*)data, (GDestroyNotify)free_user_data );
}

void folder_select_dialog (const gchar* title,
                               const gchar* start)
{
    struct user_data_cb *data = g_malloc(sizeof(struct user_data_cb));
    data->title = title;
    data->patten = NULL;
    data->start = start;
    g_idle_add_full( G_PRIORITY_DEFAULT_IDLE, (GSourceFunc)wrap_select_folder_dialog_cb,  (void*)data, (GDestroyNotify)free_user_data );
}

void multi_folder_select (const gchar* title,
                               const gchar* start)
{
    struct user_data_cb *data = g_malloc(sizeof(struct user_data_cb));
    data->title = title;
    data->patten = NULL;
    data->start = start;
    g_idle_add_full( G_PRIORITY_DEFAULT_IDLE, (GSourceFunc)wrap_multi_folder_select_cb,  (void*)data, (GDestroyNotify)free_user_data );
}

void file_save_dialog (const gchar* title,
                               const gchar* start)
{
    struct user_data_cb *data = g_malloc(sizeof(struct user_data_cb));
    data->title = title;
    data->patten = NULL;
    data->start = start;
    g_idle_add_full( G_PRIORITY_DEFAULT_IDLE, (GSourceFunc)wrap_save_file_dialog_cb,  (void*)data, (GDestroyNotify)free_user_data );
}

