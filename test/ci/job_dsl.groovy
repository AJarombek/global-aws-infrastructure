/**
 * Job DSL Script for the CI trigger job.
 * @author Andrew Jarombek
 * @since 5/12/2019
 */

pipelineJob('global-aws-infrastructure-trigger') {
    triggers {
        githubPush()
    }
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        name('origin')
                        url('git@github.com:AJarombek/global-aws-infrastructure.git')
                        credentials('865da7f9-6fc8-49f3-aa56-8febd149e72b')
                    }
                    branch('master')
                }
                scriptPath('test/ci/Jenkinsfile.groovy')
            }
        }
    }
}