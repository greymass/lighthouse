import Metrics
import Prometheus
import Vapor

public func configure(_ app: Application) throws {
    let metricsClient = PrometheusClient()
    MetricsSystem.bootstrap(metricsClient)

    try routes(app)

    app.get("metrics") { req -> EventLoopFuture<String> in
        let promise = req.eventLoop.makePromise(of: String.self)

        metricsClient.collect(into: promise)
        return promise.futureResult
    }
}
