class Regexp
  def to_parse
    { '$regex' => self.source }.tap do |h|
      ops = ''
      { IGNORECASE => 'i', MULTILINE => 'm', EXTENDED => 'x' }.each do |option, value|
        ops += value unless ( self.options & option ) == 0
      end
      
      h['$options'] = ops unless ops.blank?
    end
  end
end