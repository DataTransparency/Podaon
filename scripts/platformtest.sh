: "${WORKSPACE:?There must be a WORKSPACE environment variable set}"
: "${GIT_COMMIT:?There must be a GIT_COMMIT environment variable set}"
: "${BUILD_URL:?There must be a BUILD_URL environment variable set}"
: "${GITHUB_REPO:?There must be a GITHUB_REPO environment variable set}"
: "${GITHUB_OWNER:?There must be a GITHUB_OWNER environment variable set}"
: "${GOOGLE_APP_ID:?There must be a GOOGLE_APP_ID environment variable set}"
. $(brew --prefix nvm)/nvm.sh
export GEM_HOME=$HOME/.gem
export PATH=$GEM_HOME/bin:$PATH

PLATFORM_DIR="${WORKSPACE}/ClassfitteriOS/platformtest"
rm -rf ${PLATFORM_DIR}
mkdir ${PLATFORM_DIR}


alias cftool='node_modules/classfitter-tools/lib/index.js'

GOOGLE_APP_ID=1:1096116560042:ios:bc5a416402e93b61

function join { local IFS="$1"; shift; echo "$*"; }

 i=0
 for line in $(system_profiler SPUSBDataType | sed -n -e '/iPad/,/Serial/p' -e '/iPhone/,/Serial/p' | grep "Serial Number:" | awk -F ": " '{print $2}'); do
    UDID=${line}
    udid_array[i]=${line}
    i=$(($i+1))
 done

sims=()

echo "Running tests on physical devices"

for k in "${udid_array[@]}"
    do
    cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} "ui-tests-"$k 'pending' 'running' ${BUILD_URL}
    TEST_DIR="${PLATFORM_DIR}/"$k
    TEST_REPORTS_FOLDER="${TEST_DIR}/reports/"
    rm -rf ${TEST_DIR}
    mkdir ${TEST_DIR}
    testcommand="/usr/bin/xcodebuild test -scheme ClassfitteriOS -derivedDataPath ${TEST_DIR} -workspace ${WORKSPACE}/ClassfitteriOS/ClassfitteriOS.xcworkspace -configuration Debug -destination 'platform=iOS,id=$k' GOOGLE_APP_ID=${GOOGLE_APP_ID}  -enableCodeCoverage YES"
    echo $testcommand
    eval $testcommand | ocunit2junit
    mv test-reports $TEST_REPORTS_FOLDER
    if [ ! -f ${TEST_REPORTS_FOLDER}TEST-ClassfitteriOSUITests.xml ]
    then
    cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT}  "ui-tests-"$k error 'no test results' ${BUILD_URL}
    else
    cftool setGitHubStatusFromTestResutsFile ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} ${TEST_REPORTS_FOLDER}TEST-ClassfitteriOSUITests.xml "ui-tests-"$k ${BUILD_URL}
    fi
done