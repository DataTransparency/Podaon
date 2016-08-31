: "${WORKSPACE:?There must be a WORKSPACE environment variable set}"
: "${GIT_COMMIT:?There must be a GIT_COMMIT environment variable set}"
: "${BUILD_URL:?There must be a BUILD_URL environment variable set}"
: "${GITHUB_REPO:?There must be a GITHUB_REPO environment variable set}"
: "${GITHUB_OWNER:?There must be a GITHUB_OWNER environment variable set}"
: "${GOOGLE_APP_ID:?There must be a GOOGLE_APP_ID environment variable set}"

alias cftool='node_modules/classfitter-tools/lib/index.js'

GOOGLE_APP_ID=1:1096116560042:ios:bc5a416402e93b61
TEST_DIR="${WORKSPACE}/ClassfitteriOS/test"
COVERAGE_DIR="${TEST_DIR}/coverage"
TEST_STATUS_FILE="${TEST_DIR}/status.txt"
export TEST_REPORTS_FOLDER=${TEST_DIR}/reports

rm -rf ${TEST_DIR}
mkdir ${TEST_DIR}
mkdir ${COVERAGE_DIR}

cat <<EOM > ${TEST_STATUS_FILE}
failure
EOM

cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} 'ui-tests' 'pending' 'running' ${BUILD_URL}
cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} 'unit-tests' 'pending' 'running' ${BUILD_URL}
cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} 'coverage' 'pending' 'running' ${BUILD_URL}


function join { local IFS="$1"; shift; echo "$*"; }

 i=0
 for line in $(system_profiler SPUSBDataType | sed -n -e '/iPad/,/Serial/p' -e '/iPhone/,/Serial/p' | grep "Serial Number:" | awk -F ": " '{print $2}'); do
    UDID=${line}
    udid_array[i]=${line}
    i=$(($i+1))
 done

sims=('name=iPhone 6,OS=9.3')

if [[ ${#udid_array[@]} = 0 ]]; then
    echo "Running tests on simulator"
    for j in "${sims[@]}"
        do
        DESTINATIONS="$DESTINATIONS -destination 'platform=iOS Simulator,$j'"
        # or do whatever with individual element of the array
    done
else
    echo "Running tests on physical devices"
    for j in "${udid_array[@]}"
        do
        DESTINATIONS="$DESTINATIONS -destination 'platform=iOS,id=$j'"
        # or do whatever with individual element of the array
    done
fi
export TEST_REPORTS_FOLDER=${TEST_DIR}/reports
testcommand="/usr/bin/xcodebuild build test -scheme ClassfitteriOS -derivedDataPath ${TEST_DIR} -workspace ${WORKSPACE}/ClassfitteriOS/ClassfitteriOS.xcworkspace -configuration Debug ${DESTINATIONS} GOOGLE_APP_ID=${GOOGLE_APP_ID} -enableCodeCoverage YES | ocunit2junit"
eval $testcommand
# generate gcovr+cobertura report -destination "platform=iOS Simulator,name=iPhone 6 plus,OS=9.3" -destination "platform=iOS Simulator,name=iPhone 6,OS=10.0" -destination "platform=iOS Simulator,name=iPhone 6 plus,OS=10.0" -destination "platform=iOS Simulator,name=iPad Pro,OS=9.3"
/usr/local/bin/gcovr --object-directory=${TEST_DIR}/Logs/Test/ --root=. --xml-pretty --gcov-exclude='.*#(?:ConnectSDKTests|Frameworks)#.*' --print-summary --output="${COVERAGE_DIR}/coverage.xml"

rm -rf ${TEST_STATUS_FILE}
cat <<EOM > ${TEST_STATUS_FILE}
success
EOM