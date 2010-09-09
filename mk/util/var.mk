#
# Some useful stuff lives here.
#
# Author: Eldar Abusalimov
#


define var_info
$(call assert_called,var_info,$0) \
  $(call assert,$1,Variable name is empty) Variable [$1] info:
   flavor: [$(flavor $1)]
   origin: [$(origin $1)]
    value: [$(value $1)]
expansion: [$($1)]

endef

# eval is 3.81 bug (Savannah #27394) workaround.
${eval $( \
  )$(\n)define __var_define_mk$(       \
  )$(\n)define $$1$(\n)$$2$(\n)endef$( \
  )$(\n)endef$(                        \
)}

${eval $( \
  )$(\n)define __var_assign_recursive_mk$( \
  )$(\n)$(call __var_define_mk,$$1,$$2)$(  \
  )$(\n)endef$(                            \
)}

__var_assign_template_mk_def = ${eval $(                \
  )$(\n)define __var_assign_$(strip $1)_mk$(            \
  )$(\n)$(call __var_define_mk,__var_assign_tmp,$$2)$(  \
  )$(\n)$$1 $2 $$$$(__var_assign_tmp)$(                 \
  )$(\n)endef$(                                         \
)}

$(call __var_assign_template_mk_def,simple,:=)
$(call __var_assign_template_mk_def,append,+=)
$(call __var_assign_template_mk_def,conditional,?=)

ifeq (0,1)
var_assign_recursive = \
  $(call assert_called,var_assign_recursive,$0)$(call __var_assign,$1 =,$2)
var_assign_recursive = \
  ${eval $(__var_assign_recursive_mk)}

else

${eval $(                                             \
  )$(\n)define var_assign_recursive$(                 \
  )$(\n)$${eval $(value __var_assign_recursive_mk)}$( \
  )$(\n)endef$(                                       \
)}
endif

var_assign_simple = \
  $(call assert_called,var_assign_simple,$0)$(call __var_assign,$1:=,$2)
var_assign_simple = \
  ${eval $(__var_assign_simple_mk)}

var_assign_append = \
  $(call assert_called,var_assign_append,$0)$(call __var_assign,$1+=,$2)

var_assign_conditional = \
  $(call assert_called,var_assign_conditional,$0)$(call __var_assign,$1?=,$2)

ifeq ($(MAKE_VERSION),3.81)
var_assign_undefined = $(strip \
  $(call assert_called,var_assign_undefined,$0) \
  $(if $(filter-out undefined,$(origin $1)),$(call __var_assign,$1:=,)) \
)
else # Since version 3.82 GNU Make provides true 'undefine' directive.
var_assign_undefined = \
  $(call assert_called,var_assign_undefined,$0)$(call __var_assign,undefine $1,)
endif

__var_assign = $(strip \
  $(call assert,$(strip $1),Must specify target variable name) \
  $(call assert,$(filter undefined file,$(origin $1)), \
    Invalid origin of target variable [$1] : [$(origin $1)]) \
  $(eval $(call escape,$1) $(empty)$2$(empty)) \
)

var_define   = \
  $(call assert_called,var_define,$0)$(call var_assign_recursive,$1,$2)
var_undefine = \
  $(call assert_called,var_undefine,$0)$(call var_assign_undefined,$1,$2)

var_swap = $(strip \
  $(call assert_called,var_swap,$0) \
  $(call __var_swap,$1,$2,__var_swap_tmp) \
)
__var_swap = \
  $(call var_assign_$(flavor $1),$3,$(value $1)) \
  $(call var_assign_$(flavor $2),$1,$(value $2)) \
  $(call var_assign_$(flavor $3),$2,$(value $3))

var_save = $(strip \
  $(call assert_called,var_save,$0) \
  $(call set,__var_value,$1,$(value $1)) \
  $(call set,__var_flavor,$1,$(flavor $1)) \
)
var_restore = $(strip \
  $(call assert_called,var_restore,$0) \
  $(call var_assign_$(call get,__var_flavor,$1),$1,$(call get,__var_value,$1))\
)

