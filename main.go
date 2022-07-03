package main

import (
	"github.com/gorilla/mux"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"log"
	"net/http"
	"os"
	"strconv"
	"time"
)

var simpleCounter = promauto.NewCounter(prometheus.CounterOpts{
	Name: "simple",
	Help: "Increments when /simple handler is called",
})

var customGauge = promauto.NewGauge(prometheus.GaugeOpts{
	Name: "custom",
	Help: "Custom gauge used to scale app instances",
})

var requestDuration = promauto.NewHistogramVec(
	prometheus.HistogramOpts{
		Name: "request_duration_seconds",
		Help: "A histogram of latencies for requests.",
	},
	[]string{"code", "method", "handler"},
)

func incrAdd(counterSlice []prometheus.Counter) {
	for {
		for _, counter := range counterSlice {
			counter.Inc()
		}
		time.Sleep(1 * time.Second)
	}
}

func gaugeInc(gaugeSlice []prometheus.Gauge) {
	for {
		for _, gauge := range gaugeSlice {
			gauge.Inc()
			time.Sleep(2 * time.Nanosecond)
		}
		time.Sleep(2 * time.Second)
	}
}

func gaugeDec(gauge prometheus.Gauge) {
	for {
		time.Sleep(time.Second)
		gauge.Dec()
	}
}

func main() {

	counterSlice := []prometheus.Counter{}
	counterSlice2 := []prometheus.Counter{}
	//counterSlice3 := []prometheus.Counter{}
	//counterSlice4 := []prometheus.Counter{}
	gaugeSlice := []prometheus.Gauge{}

	for i := 0; i < 5000; i++ {
		//gauge := promauto.NewGauge(prometheus.GaugeOpts{
		//	Name: "custom" + strconv.Itoa(i),
		//	Help: "Custom gauge used to scale app instances",
		//})

		//counter := promauto.NewCounter(prometheus.CounterOpts{
		//	Name: "simple" + strconv.Itoa(i),
		//	Help: "Increments when /simple handler is called",
		//})

		gaugeSlice = append(gaugeSlice, promauto.NewGauge(prometheus.GaugeOpts{
			Name: "custom" + strconv.Itoa(i),
			Help: "Custom gauge used to scale app instances",
		}))

		counterSlice = append(counterSlice, promauto.NewCounter(prometheus.CounterOpts{
			Name: "simple" + strconv.Itoa(i),
			Help: "Increments when /simple handler is called",
		}))

		counterSlice2 = append(counterSlice2, promauto.NewCounter(prometheus.CounterOpts{
			Name: "simpleCounter" + strconv.Itoa(i),
			Help: "Increments when /simple handler is called",
		}))

		//counterSlice3 = append(counterSlice, promauto.NewCounter(prometheus.CounterOpts{
		//	Name: "simpleCounter" + strconv.Itoa(i),
		//	Help: "Increments when /simple handler is called",
		//}))
		//
		//counterSlice4 = append(counterSlice, promauto.NewCounter(prometheus.CounterOpts{
		//	Name: "simpleCounter" + strconv.Itoa(i),
		//	Help: "Increments when /simple handler is called",
		//}))

		//go gaugeInc(gauge)
		//go gaugeDec(gauge)
		//go incrAdd(counter2)
		//go incrAdd(counter3)
	}

	go incrAdd(counterSlice)
	go incrAdd(counterSlice2)
	go gaugeInc(gaugeSlice)

	router := mux.NewRouter()
	staticPath := "./static"

	router.Handle("/", http.FileServer(http.Dir(staticPath)))
	router.Handle("/metrics", promhttp.Handler())

	router.HandleFunc("/simple", instrument(simple, "simple")).Methods(http.MethodGet)
	router.HandleFunc("/high_latency", instrument(highLatency, "high_latency")).Methods(http.MethodGet)
	router.HandleFunc("/custom_metric", instrument(customMetric, "custom_metric"))

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Starting server on port http://localhost:%s\n", port)
	log.Fatal(http.ListenAndServe(":"+port, router))
}

func instrument(handlerFunc http.HandlerFunc, name string) http.HandlerFunc {
	handlerDuration, err := requestDuration.CurryWith(prometheus.Labels{
		"handler": name,
	})

	if err != nil {
		panic(err)
	}

	return promhttp.InstrumentHandlerDuration(handlerDuration, handlerFunc)
}

func simple(w http.ResponseWriter, _ *http.Request) {
	simpleCounter.Inc()
	w.Write([]byte("{}"))
}

func highLatency(w http.ResponseWriter, _ *http.Request) {
	time.Sleep(2 * time.Second)
	w.Write([]byte("{}"))
}

func customMetric(w http.ResponseWriter, r *http.Request) {
	if r.FormValue("inc") != "" {
		customGauge.Inc()
	} else {
		customGauge.Dec()
	}

	w.Write([]byte("{}"))
}
