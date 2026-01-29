//
//  MainViewController+ShowCalendarDelegate+Extension
//  App
//
//  Created by Jarret on 14/01/2026.
//

import EventKitUI

extension MainViewController: ShowCalendarDelegate {

    func present(_ viewModel: CalendarViewModel) {
        DispatchQueue.main.async { [unowned self] in
            let calendarService = CalendarService()
            let event = calendarService.createEvent(from: viewModel.event)

            let eventController = EKEventEditViewController()
            eventController.editViewDelegate = self
            eventController.eventStore = calendarService.store
            eventController.event = event

            self.present(eventController, animated: true)
        }
    }
}

extension MainViewController: EKEventEditViewDelegate {

    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        DispatchQueue.main.async { [weak controller, weak self] in
            guard let self else { return }
            calendarPlugin.didComplete(with: action.toCalendarPluginAction())
            controller?.dismiss(animated: true)
        }
    }
}
