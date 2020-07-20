# https://www.codewars.com/kata/5993c1d917bc97d05d000068/train/ruby

# Main function, should return string
def regex_divisible_by(n)
  return '(0|1)*' if n == 1
  fsm = FinitStateMachine.new(n)
 # p "FSM(#{n}): #{fsm.nodes}"

  fsm.find_state_complexes()
 # p "State complexes: #{fsm.state_complexes}, total length: #{fsm.state_complexes.map(&:join).join.length}"

  regexp = fsm.find_regexp
 # p regexp
  regexp
end


class FinitStateMachine
  attr_reader :nodes, :state_complexes

  def initialize(divider)
    @n = divider
    @state_complexes = Array.new(@n) {Array.new()}
    # node index is FSM state
    @nodes = []
    @n.times do |state|
      # state index is a transition, value is a direction
      @nodes[state] = [transition(state, '0'), transition(state, '1')]
    end
  end

  def transition(state, x)
    ((state.to_s(2) + x).to_i(2) % @n).to_s(2)
  end

  # x_path is closed path from state to itself without repeating states
  def find_x_paths(exit_state = 0, state = 0, path = [], tr = nil)
    if state == exit_state and tr
      path << tr
      path << state
      @state_complexes[exit_state] << path[1...-1]
      return
    end
    return if path.include?(state)

    path << tr if tr
    path << state
    find_x_paths(exit_state, @nodes[state][0].to_i(2), path.clone, '0')
    find_x_paths(exit_state, @nodes[state][1].to_i(2), path.clone, '1')
  end

  def find_state_complexes
    @n.times do |s|
      find_x_paths(s, s)
    end
  end

  def initial_state_complex
    [[0]]
  end

  # conditional complex of states is complex of states
  # without paths including any of 'condition' states
  def conditional_complex_of_states(complex, condition)
    return complex if complex.is_a? String
    return @state_complexes[complex].reject{ |path| (path & condition).any? }
  end

  # expands expression. any strings ignores, any integers becomes
  # conditional complex of states
  def expansion(exp, prev = [])
    #p "Prev states: #{prev}, exporession to expansion: #{exp}"
    return exp if exp.is_a? String
    return if exp.empty?
  
    unless exp.flatten.detect{|s| s.is_a? Integer}
      return exp.join + '*'
    end

    result = exp.map do |path|
      pprev = prev.clone
      path.map do |s|
        subst = conditional_complex_of_states(s, pprev)
        pprev << s if s.is_a? Integer
        expansion(subst, pprev)
      end
    end

    flatten_expression(result)
  end

  # concludes each path of expression in brackets, divides them with '|',
  # concludes all expression in brackets with Kleene star
  def flatten_expression(exp)
    (exp.length-1).times{ |i| exp.insert(i*2+1, ')|(') }
    exp.flatten!(1)
    exp.unshift('((')
    exp << '))*'
    exp
  end

  def find_regexp

    "^" + expansion(initial_state_complex).join + "$"
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
for j in 1..9 do
  for i in 1..100 do
    data2 << [j, i, i%j == 0]
  end
end

data2.compact!

# data2.each{ |n,s,exp|
#   regexp = Regexp.new(regex_divisible_by(n))

#   act = regexp.match?(s.to_s(2))
#   p act == exp ? "SUCCESS on #{s}/#{n}" : "FAIL: #{s}/#{n} should be #{exp}"
# }


n = 12
fsm = FinitStateMachine.new(n)
p "FSM(#{n}): #{fsm.nodes}"

fsm.find_state_complexes()
p "State complexes: #{fsm.state_complexes}, total length: #{fsm.state_complexes.map(&:join).join.length}"
p "Initial state complex: #{fsm.state_complexes[0]}, total length: #{fsm.state_complexes[0].map(&:join).join.length}"

regexp = fsm.find_regexp
p regexp
