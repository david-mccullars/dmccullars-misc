FORMAT = Regexp.new <<-END.strip, Regexp::MULTILINE
K \\d+
svn:ignore
V \\d+
(.*?)

(K \\d+|END)
END

ignores = Dir.glob('**/.svn/dir-prop-base', File::FNM_DOTMATCH).map do |f|
  if FORMAT.match File.read(f)
    dir = File.dirname(File.dirname(f))
    $1.split(/\n+/).map(&:strip).reject do |item|
      item =~ /=|:|\.sw.$/ || item.strip.empty?
    end.map do |item|
      item = File.join(dir, item) unless dir == '.'
      '/' + item.gsub("/+\*?$", '')
    end
  end
end + %w(*.o *.sw? .svn /buildbox /distro *.so)

File.open('.gitignore', 'w') do |io|
  ignores.flatten.compact.sort.uniq.each do |item|
    io.puts item unless item =~ %r{/\.git}
  end
  io.puts
  io.puts <<-END
!/distro
/distro/*
!/distro/centos
/distro/centos/*
!/distro/centos/6.0
/distro/centos/6.0/*
!/distro/centos/6.0/x86_64
/distro/centos/6.0/x86_64/*
!/distro/centos/6.0/x86_64/packages
/distro/centos/6.0/x86_64/packages/*
!/distro/centos/6.0/x86_64/packages/custom
/distro/centos/6.0/x86_64/packages/custom/*
!/distro/fedora
/distro/fedora/*
!/distro/fedora/8
/distro/fedora/8/*
!/distro/fedora/8/i386
/distro/fedora/8/i386/*
!/distro/fedora/8/i386/packages
/distro/fedora/8/i386/packages/*
!/distro/fedora/8/i386/packages/custom
/distro/fedora/8/i386/packages/custom/*
!/distro/fedora/8/i386/packages/stock
/distro/fedora/8/i386/packages/stock/*
!/distro/fedora/8/i386/packages/updates
/distro/fedora/8/i386/packages/updates/*
!/dev_tools
/dev_tools/*
!/dev_tools/rva_ruby_debug_rpms
/dev_tools/rva_ruby_debug_rpms/*
!/custom_patches
/custom_patches/*
!/custom_patches/BF-9869
/custom_patches/BF-9869/*
!/custom_patches/BF-9869/install_and_configure_kdump
/custom_patches/BF-9869/install_and_configure_kdump/*
END
end
