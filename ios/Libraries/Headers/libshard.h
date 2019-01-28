#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>

typedef struct IOSViewManager IOSViewManager;

typedef struct {
  void *root_ptr;
} IOSRoot;

typedef struct {
  float width;
  float height;
} CSize;

typedef struct {
  const void *swift_ptr;
  void (*set_frame)(const void*, float, float, float, float, const char**);
  void (*set_prop)(const void*, const char*, const char*, const char**);
  void (*add_child)(const void*, const void*, const char**);
  CSize (*measure)(const void*, const CSize*, const char**);
} IOSView;

IOSRoot shard_render(IOSViewManager *view_manager,
                     const void *context,
                     const char *json,
                     const char **error);

void shard_root_free(IOSRoot root);

const void *shard_root_get_view(IOSRoot root);

void shard_root_measure(IOSRoot root, CSize size, const char **error);

void shard_view_free(IOSView *view);

void shard_view_manager_free(IOSViewManager *view_manager);

const IOSViewManager *shard_view_manager_new(const void *swift_ptr,
                                             IOSView *(*create_view)(const void*, const void*, const char*, const char**));

IOSView *shard_view_new(const void *swift_ptr,
                        void (*set_frame)(const void*, float, float, float, float, const char**),
                        void (*set_prop)(const void*, const char*, const char*, const char**),
                        void (*add_child)(const void*, const void*, const char**),
                        CSize (*measure)(const void*, const CSize*, const char**));
