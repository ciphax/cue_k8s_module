package api

import (
	core "cue.dev/x/k8s.io/api/core/v1"
)

#Module: {
	objects: service: core.#Service & {
		spec: {
			let pod = objects.deployment.spec.template
			selector: pod.metadata.labels
			ports: [{
				let containerPort = pod.spec.containers[0].ports[0]
				port:       containerPort.containerPort
				targetPort: containerPort.name
			}]
		}
	}
}
