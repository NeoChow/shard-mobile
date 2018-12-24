#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>

void vml_json_get_kind(const char *json_str,
                       const void *context,
                       void (*callback)(const void*, const char*));
