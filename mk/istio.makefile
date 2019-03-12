define istio_resources
	helm template tmp/istio/install/kubernetes/helm/istio \
			--name istio \
			--namespace istio-system \
			-f istio-cfg.yaml
endef

.PHONY: istio-setup
istio-setup: tmp tmp/istio bootstrap
	@# Add the istio control plane with all configuration
	kubectl create ns $(ISTIO_NS)
	$(call istio_resources) | \
		kubectl -n $(ISTIO_NS) apply -f -
	$(MAKE) istio-wait

.PHONY: istio-wait
istio-wait:
	@# Wait for the control plane to become healthy
	kubectl -n $(ISTIO_NS) get deploy | \
		awk '{ print $$1 }' | \
		tail -n+2 | \
		xargs -IR kubectl -n $(ISTIO_NS) rollout status deploy R

.PHONY: istio-clean
istio-clean:
	@# Remove the istio control plane with all configuration
	$(call istio_resources) | \
		kubectl -n $(ISTIO_NS) delete -f - || true
	kubectl delete ns $(ISTIO_NS)

tmp/istio:
	@# Download the latest release of istio locally
	cd tmp && \
		curl -sL https://git.io/getLatestIstio | sh - && \
		mv istio-* istio
