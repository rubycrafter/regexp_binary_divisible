# https://www.codewars.com/kata/5993c1d917bc97d05d000068/train/ruby

def regex_divisible_by(n)
    fsm = FinitStateMachine.new(n)
    p "FSM(#{n}): #{fsm.nodes}"
  
    fsm.find_state_complexes()
    p "State complexes: #{fsm.state_complexes}, total length: #{fsm.state_complexes.map(&:join).join.length}"
  
    regexp = fsm.find_regexp
    p regexp
    regexp
  end
    
  class FinitStateMachine
    attr_reader :nodes, :state, :state_complexes
  
    def initialize(n)
      @n = n
      @state_complexes = Array.new(@n) {Array.new()}
      @nodes = {}
      n.times do |state|
        @nodes[state] = [transition(state, '0', n), transition(state, '1', n)]
      end
    end
  
    def transition(state, x, n)
      ((state.to_s(2) + x).to_i(2) % n).to_s(2)
    end
  
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

    # TODO: сократить дефендером
    def conditional_complex_of_states(complex, condition)
      if complex.is_a? String
        return complex
      else
        return @state_complexes[complex].reject{ |path| (path & condition).any? }
      end
    end

    def expansion(exp, prev = [])
      p "Expression to expansion: #{exp}"
      return "(#{exp})*" if exp.is_a? String
      return exp if !(exp.flatten.detect{|s| s.is_a? Integer})
      result = exp.map do |path|
        pprev = prev.clone
        path.map do |s|
          subst = conditional_complex_of_states(s, prev)
          prev << s if s.is_a? Integer
          subst = expansion(subst, prev)
        end
      end

      (result.length-1).times{ |i| result.insert(i*2+1, '|') }
      result.flatten!(1)
      result.unshift('(')
      result << ')*'

      p "Expression result: #{result}"
      result
    end
    
    def find_regexp
      result = initial_state_complex
      result = expansion(result)  

      p result
      
      "^" + result.join + "$"
    end
  end


  data = [ # divisor, input,      expect
    [4,      988.to_s(2),  true],
]
  data.each{ |n,s,exp|
    act = Regexp.new(regex_divisible_by(n)).match?(s)
    p act == exp ? 'SUCCESS' : 'FAIL'
  }