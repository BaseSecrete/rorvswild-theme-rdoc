#!/usr/bin/env ruby

$LOAD_PATH.prepend(File.expand_path(File.dirname(__FILE__)) + "/lib")

require "rdoc"
require "rorvswild_theme_rdoc"

RDoc::RDoc.new.document(ARGV)
