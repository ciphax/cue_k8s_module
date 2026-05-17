package api

import (
	"example.com/common"
)

#Module: M={
	objects: deployment: common.#Deployment & {
		spec: template: spec: containers: [{
			"name":  M.name
			"image": M.image.full
			ports: [{
				name:          "http"
				containerPort: 8080
			}]
		}]
	}
}
