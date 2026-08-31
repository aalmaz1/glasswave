import { beforeEach, describe, expect, it, vi } from "vitest";

const isNativeApp = vi.fn(() => true);
const getPlatform = vi.fn(() => "android");

vi.mock("./capDetect", () => ({
  isNativeApp: () => isNativeApp(),
  getPlatform: () => getPlatform(),
}));

const LocalNotifications = {
  checkPermissions: vi.fn(),
  requestPermissions: vi.fn(),
  checkExactNotificationSetting: vi.fn(),
  schedule: vi.fn(),
  cancel: vi.fn(),
  createChannel: vi.fn(),
  deleteChannel: vi.fn(),
};

vi.mock("@capacitor/local-notifications", () => ({
  LocalNotifications,
}));

import {
  cancelReminderNotification,
  ensureNotificationPermission,
  hasNotificationPermission,
  scheduleReminderNotification,
  syncNativeReminders,
} from "./notifications";

function futureDate(msAhead = 60_000): Date {
  return new Date(Date.now() + msAhead);
}

describe("notification permissions", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    isNativeApp.mockReturnValue(true);
    getPlatform.mockReturnValue("android");
    LocalNotifications.deleteChannel.mockResolvedValue(undefined);
    LocalNotifications.createChannel.mockResolvedValue(undefined);
    LocalNotifications.cancel.mockResolvedValue(undefined);
    LocalNotifications.schedule.mockResolvedValue({ notifications: [] });
    LocalNotifications.checkExactNotificationSetting.mockResolvedValue({
      exact_alarm: "denied",
    });
  });

  it("hasNotificationPermission is true only when display is granted", async () => {
    LocalNotifications.checkPermissions.mockResolvedValue({ display: "prompt" });
    expect(await hasNotificationPermission()).toBe(false);
    expect(LocalNotifications.requestPermissions).not.toHaveBeenCalled();

    LocalNotifications.checkPermissions.mockResolvedValue({ display: "granted" });
    expect(await hasNotificationPermission()).toBe(true);
  });

  it("ensureNotificationPermission requests the system dialog when not granted", async () => {
    LocalNotifications.checkPermissions.mockResolvedValue({ display: "prompt" });
    LocalNotifications.requestPermissions.mockResolvedValue({ display: "granted" });
    expect(await ensureNotificationPermission()).toBe(true);
    expect(LocalNotifications.requestPermissions).toHaveBeenCalledTimes(1);
  });

  it("ensureNotificationPermission does not re-prompt when already granted", async () => {
    LocalNotifications.checkPermissions.mockResolvedValue({ display: "granted" });
    expect(await ensureNotificationPermission()).toBe(true);
    expect(LocalNotifications.requestPermissions).not.toHaveBeenCalled();
  });
});

describe("scheduleReminderNotification", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    isNativeApp.mockReturnValue(true);
    getPlatform.mockReturnValue("android");
    LocalNotifications.deleteChannel.mockResolvedValue(undefined);
    LocalNotifications.createChannel.mockResolvedValue(undefined);
    LocalNotifications.cancel.mockResolvedValue(undefined);
    LocalNotifications.schedule.mockResolvedValue({ notifications: [] });
    LocalNotifications.checkExactNotificationSetting.mockResolvedValue({
      exact_alarm: "denied",
    });
  });

  it("does not call schedule() when permission is missing (avoids Capacitor 8.3 exact-alarm settings jump)", async () => {
    LocalNotifications.checkPermissions.mockResolvedValue({ display: "denied" });
    await scheduleReminderNotification("note-1", "Title", "Body", futureDate());
    expect(LocalNotifications.schedule).not.toHaveBeenCalled();
    expect(LocalNotifications.requestPermissions).not.toHaveBeenCalled();
  });

  it("does not schedule past or invalid dates", async () => {
    LocalNotifications.checkPermissions.mockResolvedValue({ display: "granted" });
    await scheduleReminderNotification("note-1", "Title", "Body", new Date(Date.now() - 1000));
    await scheduleReminderNotification("note-1", "Title", "Body", new Date("not-a-date"));
    expect(LocalNotifications.schedule).not.toHaveBeenCalled();
  });

  it("schedules with isExactNotification false when exact alarms are not granted", async () => {
    LocalNotifications.checkPermissions.mockResolvedValue({ display: "granted" });
    LocalNotifications.checkExactNotificationSetting.mockResolvedValue({
      exact_alarm: "denied",
    });
    const at = futureDate();
    await scheduleReminderNotification("local-42", "Buy milk", "Don't forget", at);
    expect(LocalNotifications.schedule).toHaveBeenCalledTimes(1);
    const payload = LocalNotifications.schedule.mock.calls[0][0];
    expect(payload.notifications).toHaveLength(1);
    const n = payload.notifications[0];
    expect(n.title).toBe("Buy milk");
    expect(n.body).toBe("Don't forget");
    expect(n.channelId).toBe("glasswave-reminders-v3");
    expect(n.smallIcon).toBe("ic_stat_notify");
    expect(n.schedule).toEqual({ at, allowWhileIdle: true });
    expect(n.isExactNotification).toBe(false);
  });

  it("uses exact alarms only when the OS already allows them", async () => {
    LocalNotifications.checkPermissions.mockResolvedValue({ display: "granted" });
    LocalNotifications.checkExactNotificationSetting.mockResolvedValue({
      exact_alarm: "granted",
    });
    await scheduleReminderNotification("local-42", "Title", "Body", futureDate());
    const n = LocalNotifications.schedule.mock.calls[0][0].notifications[0];
    expect(n.isExactNotification).toBe(true);
  });

  it("is a no-op on web", async () => {
    isNativeApp.mockReturnValue(false);
    LocalNotifications.checkPermissions.mockResolvedValue({ display: "granted" });
    await scheduleReminderNotification("note-1", "Title", "Body", futureDate());
    expect(LocalNotifications.schedule).not.toHaveBeenCalled();
  });
});

describe("syncNativeReminders", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    isNativeApp.mockReturnValue(true);
    LocalNotifications.deleteChannel.mockResolvedValue(undefined);
    LocalNotifications.createChannel.mockResolvedValue(undefined);
    LocalNotifications.cancel.mockResolvedValue(undefined);
    LocalNotifications.schedule.mockResolvedValue({ notifications: [] });
    LocalNotifications.checkExactNotificationSetting.mockResolvedValue({
      exact_alarm: "denied",
    });
  });

  it("does not prompt on startup when permission is missing", async () => {
    LocalNotifications.checkPermissions.mockResolvedValue({ display: "prompt" });
    await syncNativeReminders([{ key: "local-1", title: "A", body: "B", at: futureDate() }]);
    expect(LocalNotifications.requestPermissions).not.toHaveBeenCalled();
    expect(LocalNotifications.schedule).not.toHaveBeenCalled();
  });

  it("re-arms future reminders when permission is already granted", async () => {
    LocalNotifications.checkPermissions.mockResolvedValue({ display: "granted" });
    await syncNativeReminders([
      { key: "local-1", title: "A", body: "B", at: futureDate() },
      { key: "local-2", title: "Old", body: "x", at: new Date(Date.now() - 5000) },
    ]);
    expect(LocalNotifications.schedule).toHaveBeenCalledTimes(1);
  });
});

describe("cancelReminderNotification", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    isNativeApp.mockReturnValue(true);
    LocalNotifications.cancel.mockResolvedValue(undefined);
  });

  it("cancels the derived id on native", async () => {
    await cancelReminderNotification("local-42");
    expect(LocalNotifications.cancel).toHaveBeenCalledTimes(1);
    const arg = LocalNotifications.cancel.mock.calls[0][0];
    expect(arg.notifications).toHaveLength(1);
    expect(typeof arg.notifications[0].id).toBe("number");
  });
});
