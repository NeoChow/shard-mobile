#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>

typedef struct IOSViewManager IOSViewManager;

typedef struct {
  float width;
  float height;
} CSize;

typedef struct {
  const void *context;
  void (*set_frame)(const void*, float, float, float, float);
  void (*set_prop)(const void*, const char*, const char*);
  void (*add_child)(const void*, const void*);
  CSize (*measure)(const void*, CSize);
} IOSView;

const IOSView *vml_render(IOSViewManager *view_manager, const char *json, CSize size);

void vml_view_free(IOSView *view);

void vml_view_manager_free(IOSViewManager *view_manager);

const IOSViewManager *vml_view_manager_new(const void *context,
                                           IOSView *(*create_view)(const void*, const char*));

IOSView *vml_view_new(const void *context,
                      void (*set_frame)(const void*, float, float, float, float),
                      void (*set_prop)(const void*, const char*, const char*),
                      void (*add_child)(const void*, const void*),
                      CSize (*measure)(const void*, CSize));
