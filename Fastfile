default_platform(:ios)

platform :ios do
  
  desc "Build the iOS app for sideloading"
  lane :build_for_sideload do
    build_app(
      workspace: "RPGGame.xcworkspace",
      scheme: "RPGGame",
      configuration: "Release",
      sdk: "iphoneos",
      derived_data_path: "build",
      archive_path: "build/RPGGame.xcarchive",
      destination: "generic/platform=iOS",
      skip_package_ipa: false,
      skip_package_pkg: true,
      destination_general_file_path: "build/ipa",
      output_directory: "build/ipa",
      output_name: "RPGGame-sideload",
      code_sign_identity: "",
      provisioning_profile_specifier: "",
      signingStyle: "automatic",
      exportMethod: "ad-hoc",
      exportOptions: {
        signingStyle: "automatic",
        stripSwiftSymbols: true,
        teamID: "",
        method: "ad-hoc"
      },
      verbose: true,
      silent: false
    )
    
    # Create zip for distribution
    sh("cd build/ipa && zip -r -q ../RPGGame-sideload.ipa *.app && cd ../..")
  end

  desc "Build and test the app"
  lane :build_and_test do
    scan(
      scheme: "RPGGame",
      configuration: "Debug",
      sdk: "iphonesimulator",
      derived_data_path: "build",
      devices: ["iPhone 15"],
      clean: true,
      skip_testing: false,
      output_types: "html,junit",
      output_directory: "build/test-reports",
      suppress_xcode_output: false,
      verbose: true
    )
  end

  desc "Run SwiftLint"
  lane :lint do
    swiftlint(
      mode: :lint,
      strict: true,
      reporter: "json",
      output_file: "build/swiftlint-report.json"
    )
  end

  desc "Build Release IPA"
  lane :build_release do
    increment_build_number(xcodeproj: "RPGGame.xcodeproj")
    
    build_app(
      workspace: "RPGGame.xcworkspace",
      scheme: "RPGGame",
      configuration: "Release",
      sdk: "iphoneos",
      derived_data_path: "build",
      archive_path: "build/RPGGame-Release.xcarchive",
      destination: "generic/platform=iOS",
      export_method: "ad-hoc",
      output_directory: "build/release",
      output_name: "RPGGame",
      clean: true,
      verbose: true
    )
  end

  desc "Run all tests"
  lane :test do
    scan(
      scheme: "RPGGame",
      devices: ["iPhone 15 Pro"],
      clean: true,
      configuration: "Debug",
      skip_slack: true,
      suppress_xcode_output: false
    )
  end

  desc "Generate build report"
  lane :generate_report do
    sh("mkdir -p build/reports")
    sh("echo 'Build Report Generated at #{Time.now}' > build/reports/build-report.txt")
    sh("xcodebuild -showsdks >> build/reports/build-report.txt")
  end

  desc "Deploy to GitHub"
  lane :deploy_github do
    set_github_release(
      repository_name: "yourusername/rpg-game-ios",
      api_token: ENV["GITHUB_TOKEN"],
      name: "Release #{get_version_number}",
      tag_name: "v#{get_version_number}",
      description: "iOS RPG Game v#{get_version_number}",
      commitish: "main",
      upload_assets: ["build/release/RPGGame.ipa"]
    )
  end

  desc "Pre-build checks"
  lane :pre_build_checks do
    # Check Xcode version
    sh("xcodebuild -version")
    
    # Verify scheme exists
    sh("xcodebuild -list -project RPGGame.xcodeproj | grep RPGGame")
    
    # Check dependencies
    sh("which swiftlint")
    sh("which xcpretty")
  end

  desc "Clean build artifacts"
  lane :clean do
    clear_derived_data
    sh("rm -rf build")
    sh("rm -rf build.log")
  end

end
