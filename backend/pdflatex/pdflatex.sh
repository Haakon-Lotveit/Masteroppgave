#!/bin/bash

echo "$*" | sbcl --noinform --load 'compile.lisp' --eval "(external-entry-point)"
