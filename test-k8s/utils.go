/**
 * Reusable utility functions used for testing Kubernetes infrastructure.
 * Author: Andrew Jarombek
 * Date: 7/5/2020
 */

package main

import "testing"

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