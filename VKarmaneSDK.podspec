#
# Be sure to run `pod lib lint VKarmaneSDK.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
  s.name             = 'VKarmaneSDK'
  s.version          = '1.0.0'
  s.summary          = 'Access to content of VKarmane App with SDK.'
  s.description      = 'VKarmane application SDK to provide convenient cross-application interaction'

  s.homepage         = 'https://github.com/TinkoffCreditSystems/vkarmane-sdk-ios.git'
  s.license          = { :type => 'Apache License 2.0', :file => 'LICENSE.txt' }
  s.author           = { 'a.kulabukhov' => 'a.kulabukhov@tinkoff.ru' }
  s.source           = { :git => 'https://github.com/TinkoffCreditSystems/vkarmane-sdk-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'VKarmaneSDK/Classes/*.swift', 'VKarmaneSDK/Classes/Definitions/*.swift'
  s.swift_version = '4.2'

  s.subspec 'Encryption' do |es|
    es.source_files = 'VKarmaneSDK/Classes/Encryption/*.swift'
    
    es.script_phase = {
        :name => 'CommonCrypto',
        :script => 'COMMON_CRYPTO_DIR="${SDKROOT}/usr/include/CommonCrypto"
        if [ -f "${COMMON_CRYPTO_DIR}/module.modulemap" ]
            then
            echo "CommonCrypto already exists, skipping"
            else
            # This if-statement means we will only run the main script if the
            # CommonCrypto.framework directory doesn not exist because otherwise
            # the rest of the script causes a full recompile for anything
            # where CommonCrypto is a dependency
            # Do a "Clean Build Folder" to remove this directory and trigger
            # the rest of the script to run
            FRAMEWORK_DIR="${BUILT_PRODUCTS_DIR}/CommonCrypto.framework"
            if [ -d "${FRAMEWORK_DIR}" ]; then
                echo "${FRAMEWORK_DIR} already exists, so skipping the rest of the script."
                exit 0
                fi
                mkdir -p "${FRAMEWORK_DIR}/Modules"
                echo "module CommonCrypto [system] {
                header \"${SDKROOT}/usr/include/CommonCrypto/CommonCrypto.h\"
                export *
                }" >> "${FRAMEWORK_DIR}/Modules/module.modulemap"
                ln -sf "${SDKROOT}/usr/include/CommonCrypto" "${FRAMEWORK_DIR}/Headers"
                fi',
                :execution_position => :before_compile
                }
    
  end

end
