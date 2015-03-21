<% module_namespacing do -%>
class <%= class_name %><%= " < #{options[:parent].classify}" if options[:parent] %>
<% unless options[:parent] -%>
  include Opium::Model
<% end -%>
<% attributes.reject {|attr| attr.reference?}.each do |attribute| -%>
  field :<%= attribute.name %><%= ", type: #{ attribute.type_class }" if attribute.type_class %>
<% end -%>
end
<% end -%>