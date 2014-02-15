require 'fileutils'

rule(:ccobj) do
  def build(in_paths, out_paths, flags)
    sh 'gcc', '-c', '-O2 -std=gnu11 -DHAVE_CONFIG_H', '-I.', '-I./lib/', '-o', out_paths.first, *in_paths
  end
end

rule(:cxxobj) do
  def build(in_paths, out_paths, flags)
    sh 'g++', '-c', '-O2 -std=gnu11 -DHAVE_CONFIG_H', '-I.', '-I./lib/', '-o', out_paths.first, *in_paths
  end
end

rule(:cc) do
  def build(in_paths, out_paths, flags)
    sh 'gcc', '-O2 -std=gnu11 -DHAVE_CONFIG_H', '-I.', '-I./lib/', '-o', out_paths.first, *in_paths, '-lpcre'
  end
end

rule(:cxx) do
  def build(in_paths, out_paths, flags)
    sh 'g++', '-O2 -std=gnu11 -DHAVE_CONFIG_H', '-I.', '-I./lib/', '-o', out_paths.first, *in_paths
  end
end

rule(:mkdir) do
  def build(in_paths, out_paths, flags)
    out_paths.each { |path| FileUtils.mkpath(path) }
  end
end
