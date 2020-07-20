# https://www.codewars.com/kata/5993c1d917bc97d05d000068/train/ruby

# Main function, should return string
def regex_divisible_by(n)
  return '(0|1)*' if n == 1
  fsm = FinitStateMachine.new(n)
 # p "FSM(#{n}): #{fsm.nodes}"

  regexp = fsm.find_regexp
 # p regexp
  regexp
end


class FinitStateMachine
  attr_reader :nodes

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
   # p "Current state: #{state}"
   # p "Current FSM: #{@nodes}"

    # creating array of all clouseres of state
    closure_transitions = @nodes[state].find_all{ |tr, st| st == state }.map!(&:first)

    # creating full closure of state
    closure = closure_transitions.empty? ? '' : "(#{closure_transitions.join('|')})*"

   # p "Closure is: #{closure}"

    incoming = @nodes.map.with_index do |n, i|
      [n.find_all{|tr, st| st == state}[0][0], i] if n.detect{|tr, st| st == state} and i != state
    end.compact
    #p "Incoming nodes: #{incoming}"

    incoming.each do |inc_tr, n|
      @nodes[n].delete(inc_tr)
      @nodes[state].each do |out_tr, st|
        existing_tr = @nodes[n].key(st)
        @nodes[n].delete(existing_tr) if existing_tr
        new_tr = "#{inc_tr}#{closure}#{out_tr}"
        full_tr = [existing_tr, new_tr].compact.join('|')
        full_tr = "(#{full_tr})"
        @nodes[n][full_tr] = st unless st == state
      #  p "New transition from #{n}: #{full_tr} => #{st}" unless st == state
      end
    end

    @nodes.delete_at(state)
  end

  def find_regexp
    (1...@n).reverse_each do |i|
      remove_state(i)
    end

    "^(0|#{@nodes[0].keys.first})*$"
  end
end


data1 = [ # divisor, input,      expect
  [4,      44,  true],
  [1,      5,  true],
  [1,      1,  true],
  [1,      0,  true],
  [1,      11,  true],
  [2,      22,  true],
  [2,      16, true],
  [2,      13, false],
  [3,      7, false],
  [5,      65, true],
  [5,      155, true],
  [5,      3,  false],
  [5,      13, false],
  [7,      140, true],
  [7,      4793488, true],
  [10,     20, true],
  [15,     30, true],
  [16,     32, true],
  [17,     34, true],
#  [18,     18000.to_s(2), true],
  [3,      "nope",     false],
  [3,      "3",        false],
]


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
