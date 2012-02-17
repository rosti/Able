module Able

  ##
  # Able default configuration.
  # This configuration is loaded upon startup to the root directory of the project.
  #
  ABLE_DEFAULT_CONFIG = Proc.new do

    config 'default' do
      SOs = ['.dll', '.so']
      EXEs = ['', '.exe']
      LIBs = ['.a', '.lib']
      OBJs = ['.o', '.obj']
      CXXs = ['.cpp', '.cc', '.cxx', '.C', '.c++']

      # Monkey patch Rule so that we have GCC configs in here
      class Rule
        include GCC
      end

      # Assembly to objects
      OBJs.each do |suffix|
        rule '.S' => suffix do

          def build input, output
            assemble input, output, '-c'
          end
        end
      end

      # Assembly to executables
      EXEs.each do |suffix|
        rule '.S' => suffix do

          def build input, output
            assemble input, output
          end
        end
      end

      # Assembly to shared libs
      SOs.each do |suffix|
        rule '.S' => suffix do

          def build input, output
            assemble input, output, '-shared'
          end
        end
      end

      # C to objects
      OBJs.each do |suffix|
        rule '.c' => suffix do

          def extra_depends input, output
            more_deps input, output
          end

          def build input, output
            c_compile input, output, '-c'
          end

        end
      end

      # C to executables
      EXEs.each do |suffix|
        rule '.c' => suffix do

          def extra_depends input, output
            more_deps input, output
          end

          def build input, output
            c_compile input, output
          end

        end
      end

      # C to shared lib
      SOs.each do |suffix|
        rule '.c' => suffix do

          def extra_depends input, output
            more_deps input, output
          end

          def build input, output
            c_compile input, output, '-shared'
          end

        end
      end

      # C++ to object
      CXXs.each do |in_suffix|
        OBJs.each do |out_suffix|
          rule in_suffix => out_suffix do

            def extra_depends input, output
              more_deps input, output
            end

            def build input, output
              cxx_compile input, output, '-c'
            end

          end
        end
      end

      # C++ to exe
      CXXs.each do |in_suffix|
        EXEs.each do |out_suffix|
          rule in_suffix => out_suffix do

            def extra_depends input, output
              more_deps input, output
            end

            def build input, output
              cxx_compile input, output
            end

          end
        end
      end

      # C++ to shared lib
      CXXs.each do |in_suffix|
        SOs.each do |out_suffix|
          rule in_suffix => out_suffix do

            def extra_depends input, output
              more_deps input, output
            end

            def build input, output
              cxx_compile input, output, '-shared'
            end

          end
        end
      end

      # Objects to executables
      OBJs.each do |in_suffix|
        EXEs.each do |out_suffix|
          rule in_suffix => out_suffix do

            def build input, output
              link input, output
            end

          end
        end
      end

      # Objects to shared libs
      OBJs.each do |in_suffix|
        SOs.each do |out_suffix|
          rule in_suffix => out_suffix do

            def build input, output
              link input, output, '-shared'
            end

          end
        end
      end

      # Objects to objects :)
      OBJs.each do |in_suffix|
        OBJs.each do |out_suffix|
          rule in_suffix => out_suffix do

            def build input, output
              link input, output, '-r'
            end

          end
        end
      end

      # Objects to static libs
      OBJs.each do |in_suffix|
        LIBs.each do |out_suffix|
          rule in_suffix => out_suffix do

            def build input, output
              ar input, output
            end

          end
        end
      end

    end

    use config: 'default'

  end

end
