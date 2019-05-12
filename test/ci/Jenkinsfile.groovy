/**
 * Jenkinsfile which executes when the trigger job is built.
 * @author Andrew Jarombek
 * @since 5/12/2019
 */

node("master") {
    stage('global-aws-infrastructure') {
        build job: 'global-aws-infrastructure', parameters: [
            [$class: 'StringParameterValue', name: 'branchName', value: 'master']
        ]
    }
}