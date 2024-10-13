class RDoc::ClassModule
  ##
  # Get all super classes of this class in an array. The last element might be
  # a string if the name is unknown.
  def super_classes
    result = []
    parent = self
    while parent = parent.superclass
      result << parent
      return result if parent.is_a?(String)
    end
    result
  end
end
