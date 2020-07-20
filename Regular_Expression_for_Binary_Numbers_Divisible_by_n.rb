# https://www.codewars.com/kata/5993c1d917bc97d05d000068/train/ruby

# Main function, should return string
def regex_divisible_by(n)
  return '^(0|1)*$' if n == 1
  fsm = FinitStateMachine.new(n)
  fsm.find_regexp
end


class FinitStateMachine
  def initialize(divider)
    @n = divider
    # node index is FSM state
    @nodes = []
    @n.times do |state|
      # state index is a transition, value is a direction
      @nodes[state] = {'0' => transition(state, '0'),'1' => transition(state, '1')}
    end
  end

  def transition(state, x)
    ((state.to_s(2) + x).to_i(2) % @n)
  end

  def remove_state(state)
    # creating array of all closures of state
    closure_transitions = @nodes[state].find_all{ |tr, st| st == state }.map!(&:first)

    # creating full closure of state
    closure = ''
    if closure_transitions.join.length == 1 
      closure = "#{closure_transitions.join}*"
    else
      closure = "(#{closure_transitions.join('|')})*" unless closure_transitions.empty? 
    end

    incoming = @nodes.map.with_index do |n, i|
      [n.find_all{|tr, st| st == state}[0][0], i] if n.detect{|tr, st| st == state} and i != state
    end.compact

    incoming.each do |inc_tr, n|
      @nodes[n].delete(inc_tr)
      @nodes[state].each do |out_tr, st|
        existing_tr = @nodes[n].key(st)
        @nodes[n].delete(existing_tr) if existing_tr
        new_tr = "#{inc_tr}#{closure}#{out_tr}"
        full_tr = [existing_tr, new_tr].compact.join('|')
        full_tr = "(#{full_tr})" if existing_tr
        @nodes[n][full_tr] = st unless st == state
      end
    end

    @nodes.delete_at(state)
  end

  def find_regexp
    (1...@n).reverse_each do |i|
      remove_state(i)
    end

    "^#{@nodes[0].keys.first}*$"
  end
end


data2 = []
for j in 1..18 do
  for i in 1..100 do
    data2 << [j, i, i%j == 0]
  end
end

data2.compact!
data2.each{ |n,s,exp|
  regexp = Regexp.new(regex_divisible_by(n))

  act = regexp.match?(s.to_s(2))
  p act == exp ? "SUCCESS on #{s}/#{n}" : "FAIL: #{s}/#{n} should be #{exp}"
}
