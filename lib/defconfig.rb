module Able

  ##
  # Able default configuration.
  # This configuration is loaded upon startup to the root directory of the project.
  #
  ABLE_DEFAULT_CONFIG = Proc.new do

    config 'default' do

      rule '.o' => '.c' do

        def build input, output
          sh 'cc', '-c', '-o', Array(output)[0], *Array(input)
        end

        def describe input, output
          "Building: #{input.inspect} => #{output.inspect}"
        end

      end

      rule '' => '.c' do

        def build input, output
          sh 'cc', '-c', '-o', Array(output)[0], *Array(input)
        end

        def describe input, output
          "Building: #{input.inspect} => #{output.inspect}"
        end

      end


      rule '' => '.o' do

        def build input, output
          sh 'cc', '-o', Array(output)[0], *Array(input)
        end

        def describe input, output
          "Building: #{input.inspect} => #{output.inspect}"
        end

      end

    end

    use config: 'default'

  end

end
