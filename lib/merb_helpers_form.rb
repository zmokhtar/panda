# Overriding form, as SimpleDB does not provide errors on object.
module Merb::Helpers::Form
  def _singleton_form_context
    self._default_builder = Merb::Helpers::Form::Builder::ResourcefulForm
    @_singleton_form_context ||=
      self._default_builder.new(nil, nil, self)
  end
end