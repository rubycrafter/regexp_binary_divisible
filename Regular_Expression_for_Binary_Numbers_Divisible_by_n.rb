# https://www.codewars.com/kata/5993c1d917bc97d05d000068/train/ruby

def regex_divisible_by(n)
    fsm = FinitStateMachine.new(n)
    p "FSM(#{n}): #{fsm.nodes}"
  
    fsm.find_state_complexes()
    p "Initial complex: #{fsm.state_complexes[0]}, total length: #{fsm.state_complexes[0].map(&:join).join.length}"
    p "State complexes: #{fsm.state_complexes}, total length: #{fsm.state_complexes.map(&:join).join.length}"
  
    fsm.find_regexp.join
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

    def find_regexp
      result = initial_state_complex
      (@n**2).times do |i|
        puts "Result #{i}: #{result}"

        result.map! do |path|
          prev = [0]
          path.map! do |s|
            if s.is_a? String
              subst = s
            else
              subst = @state_complexes[s].reject{ |p| (p & prev).any? }
              if subst.any?
                (subst.length-1).times{ |i| subst.insert(i*2+1, '|') }
                subst.flatten!
                subst.unshift('(')
                subst << ')*'
              end
              prev << s
            end
            subst
          end
          path.flatten
        end
      end
      p result.join
      result
    end
  end


  data = [ # divisor, input,      expect
              [3,      9.to_s(2), true],
  ]
  
  data.each{ |n,s,exp|
    act = Regexp.new(regex_divisible_by(n)).match?(s)
    p act == exp ? 'SUCCESS' : 'FAIL'
  }