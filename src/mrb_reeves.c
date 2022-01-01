/*
** mrb_reeves.c - Reeves class
**
** Copyright (c) Yusuke Sangenya 2022
**
** See Copyright Notice in LICENSE
*/

#include "mruby.h"
#include "mruby/data.h"
#include "mrb_reeves.h"

#define DONE mrb_gc_arena_restore(mrb, 0);

typedef struct {
  char *str;
  mrb_int len;
} mrb_reeves_data;

static const struct mrb_data_type mrb_reeves_data_type = {
  "mrb_reeves_data", mrb_free,
};

static mrb_value mrb_reeves_init(mrb_state *mrb, mrb_value self)
{
  mrb_reeves_data *data;
  char *str;
  mrb_int len;

  data = (mrb_reeves_data *)DATA_PTR(self);
  if (data) {
    mrb_free(mrb, data);
  }
  DATA_TYPE(self) = &mrb_reeves_data_type;
  DATA_PTR(self) = NULL;

  mrb_get_args(mrb, "s", &str, &len);
  data = (mrb_reeves_data *)mrb_malloc(mrb, sizeof(mrb_reeves_data));
  data->str = str;
  data->len = len;
  DATA_PTR(self) = data;

  return self;
}

static mrb_value mrb_reeves_hello(mrb_state *mrb, mrb_value self)
{
  mrb_reeves_data *data = DATA_PTR(self);

  return mrb_str_new(mrb, data->str, data->len);
}

static mrb_value mrb_reeves_hi(mrb_state *mrb, mrb_value self)
{
  return mrb_str_new_cstr(mrb, "hi!!");
}

void mrb_reeves_gem_init(mrb_state *mrb)
{
  struct RClass *reeves;
  reeves = mrb_define_class(mrb, "Reeves", mrb->object_class);
  mrb_define_method(mrb, reeves, "initialize", mrb_reeves_init, MRB_ARGS_REQ(1));
  mrb_define_method(mrb, reeves, "hello", mrb_reeves_hello, MRB_ARGS_NONE());
  mrb_define_class_method(mrb, reeves, "hi", mrb_reeves_hi, MRB_ARGS_NONE());
  DONE;
}

void mrb_reeves_gem_final(mrb_state *mrb)
{
}

