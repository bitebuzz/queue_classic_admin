module QueueClassicAdmin
  class ApplicationController < ActionController::Base
    http_basic_authenticate_with(
      name: ENV['CF_Q_ADMIN_USER'] || 'admin',
      password: ENV['CF_Q_ADMIN_PASSWORD'] || 'qAdm1nPassw0rd',
      realm: 'GNIP streamer queues admin interface'
    )

    protected
    def filter_jobs
      @queue_classic_jobs = QueueClassicJob.order("id DESC")

      if self.class == QueueClassicScheduledJobsController
        @scoped_jobs = QueueClassicJob.scheduled
        @queue_classic_jobs = @queue_classic_jobs.scheduled
      else
        @scoped_jobs = QueueClassicJob.ready
        @queue_classic_jobs = @queue_classic_jobs.ready
      end

      if params[:q_name].present?
        @queue_classic_jobs = @queue_classic_jobs.where(q_name: params[:q_name])
      end
      if params[:search].present?
        @queue_classic_jobs = @queue_classic_jobs.search(params[:search])
      end
      if params[:sort].present?
        @queue_classic_jobs = @queue_classic_jobs.reorder("#{params[:sort]} #{params[:dir]} NULLS LAST")
      end
      @queue_classic_jobs
    end
  end
end
