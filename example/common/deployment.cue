package common

import (
	apps "cue.dev/x/k8s.io/api/apps/v1"
)

#Deployment: apps.#Deployment & {
	metadata: _
	spec: {
		selector: matchLabels: template.metadata.labels
		template: {
			"metadata": labels: metadata.labels
		}
	}
}
