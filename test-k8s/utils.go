/**
 * Reusable utility functions used for testing Kubernetes infrastructure.
 * Author: Andrew Jarombek
 * Date: 7/5/2020
 */

package main

import (
	"regexp"
	"testing"
)

// annotationsEqual logs a failure to a test suite if an annotation in the annotations map does not have its expected
//value.  Otherwise, it logs a success message and the test suite will proceed with a success code.
func annotationsEqual(t *testing.T, annotations map[string]string, name string, expectedValue string) {
	value := annotations[name]

	if expectedValue == value {
		t.Logf(
			"Annotation %v exists with its expected value.  Expected %v, got %v.",
			name,
			expectedValue,
			value,
		)
	} else {
		t.Errorf(
			"Annotation %v does not exist with its expected value.  Expected %v, got %v.",
			name,
			expectedValue,
			value,
		)
	}
}

// annotationsMatchPattern logs a failure to a test suite if an annotation in the annotations map does not match its
// expected pattern.  Otherwise, it logs a success message and the test suite will proceed with a success code.
func annotationsMatchPattern(t *testing.T, annotations map[string]string, name string, expectedPattern string) {
	value := annotations[name]
	pattern, err := regexp.Compile(expectedPattern)

	if err != nil {
		panic(err.Error())
	}

	if pattern.MatchString(value) {
		t.Logf(
			"Annotation %v exists and matches its expected pattern.  Expected %v, got %v.",
			name,
			expectedPattern,
			value,
		)
	} else {
		t.Errorf(
			"Annotation %v does not exist and match its expected pattern.  Expected %v, got %v.",
			name,
			expectedPattern,
			value,
		)
	}
}