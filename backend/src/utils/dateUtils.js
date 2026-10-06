/**
 * Date & Time Utilities for Nirmaan Business Operations & Analytics.
 * 
 * Standard Business Timezone: Asia/Kolkata (IST, UTC+05:30).
 * Consistent date boundary strategy ensures that operational periods 
 * (Today, Yesterday, Last 7 Days, Last 30 Days, Custom) are strictly 
 * evaluated according to the business's physical operating calendar day, 
 * regardless of whether the backend server or client browser is situated 
 * in UTC, US-East, or any other timezone.
 */

const DEFAULT_BUSINESS_TIMEZONE = 'Asia/Kolkata';

/**
 * Returns formatted YYYY-MM-DD string for a date in the business timezone.
 *
 * @param {Date} [date=new Date()]
 * @param {string} [timeZone=DEFAULT_BUSINESS_TIMEZONE]
 * @returns {string}
 */
function getISTDateString(date = new Date(), timeZone = DEFAULT_BUSINESS_TIMEZONE) {
  const formatter = new Intl.DateTimeFormat('en-CA', {
    timeZone,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  });
  return formatter.format(date);
}

/**
 * Returns the exact ISO-8601 start and end boundaries for "Today" in the specified timezone.
 *
 * @param {string} [timeZone=DEFAULT_BUSINESS_TIMEZONE] - IANA timezone identifier
 * @param {Date} [referenceDate=new Date()] - Optional reference date for testing boundaries
 * @returns {{ todayDateStr: string, startOfDayISO: string, endOfDayISO: string, timeZone: string }}
 */
function getTodayTimezoneRange(timeZone = DEFAULT_BUSINESS_TIMEZONE, referenceDate = new Date()) {
  const todayDateStr = getISTDateString(referenceDate, timeZone);

  // IST offset is UTC+05:30. Build exact ISO strings for midnight to end of day.
  const startOfDay = new Date(`${todayDateStr}T00:00:00.000+05:30`);
  const endOfDay = new Date(`${todayDateStr}T23:59:59.999+05:30`);

  return {
    todayDateStr,
    startOfDayISO: startOfDay.toISOString(),
    endOfDayISO: endOfDay.toISOString(),
    timeZone,
  };
}

/**
 * Determines whether a given ISO date string or Date object falls within "Today" in the business timezone.
 *
 * @param {string|Date} dateInput
 * @param {string} [timeZone=DEFAULT_BUSINESS_TIMEZONE]
 * @param {Date} [referenceDate=new Date()]
 * @returns {boolean}
 */
function isDateInTodayRange(dateInput, timeZone = DEFAULT_BUSINESS_TIMEZONE, referenceDate = new Date()) {
  if (!dateInput) return false;
  try {
    let targetDate;
    if (typeof dateInput === 'string' || typeof dateInput === 'number') {
      targetDate = new Date(dateInput);
    } else if (dateInput instanceof Date) {
      targetDate = dateInput;
    } else if (dateInput && typeof dateInput.toDate === 'function') {
      targetDate = dateInput.toDate();
    } else {
      targetDate = new Date(dateInput);
    }

    if (isNaN(targetDate.getTime())) return false;
    const { startOfDayISO, endOfDayISO } = getTodayTimezoneRange(timeZone, referenceDate);
    const targetISO = targetDate.toISOString();
    return targetISO >= startOfDayISO && targetISO <= endOfDayISO;
  } catch {
    return false;
  }
}

/**
 * Shifts an IST date string (YYYY-MM-DD) by N days.
 *
 * @param {string} dateStr - 'YYYY-MM-DD'
 * @param {number} daysDelta
 * @returns {string}
 */
function shiftDateString(dateStr, daysDelta) {
  const d = new Date(`${dateStr}T12:00:00.000+05:30`);
  d.setDate(d.getDate() + daysDelta);
  return getISTDateString(d);
}

/**
 * Generates an array of continuous date strings 'YYYY-MM-DD' between startDateStr and endDateStr inclusive.
 *
 * @param {string} startDateStr
 * @param {string} endDateStr
 * @returns {string[]}
 */
function generateDateSeries(startDateStr, endDateStr) {
  const series = [];
  let curr = startDateStr;
  const maxDays = 366; // Safeguard against runaway loops
  let count = 0;
  while (curr <= endDateStr && count < maxDays) {
    series.push(curr);
    curr = shiftDateString(curr, 1);
    count++;
  }
  return series;
}

/**
 * Calculates start and end boundaries for analytical ranges in the business timezone (Asia/Kolkata).
 *
 * Supported range types:
 * - 'today' / 'TODAY'
 * - 'yesterday' / 'YESTERDAY'
 * - '7d' / '7D' / 'last7days'
 * - '30d' / '30D' / 'last30days'
 * - 'custom' / 'CUSTOM' (requires customStart and customEnd in YYYY-MM-DD format)
 *
 * @param {string} [rangeType='30d']
 * @param {object} [options={}]
 * @param {string} [options.customStart]
 * @param {string} [options.customEnd]
 * @param {string} [options.timeZone=DEFAULT_BUSINESS_TIMEZONE]
 * @param {Date} [options.referenceDate=new Date()]
 * @returns {{
 *   range: string,
 *   startDateStr: string,
 *   endDateStr: string,
 *   startISO: string,
 *   endISO: string,
 *   days: string[],
 *   timeZone: string
 * }}
 */
function getDateRangeBoundaries(rangeType = '30d', options = {}) {
  const {
    customStart,
    customEnd,
    timeZone = DEFAULT_BUSINESS_TIMEZONE,
    referenceDate = new Date(),
  } = options;

  const normalizedRange = (rangeType || '30d').toLowerCase().trim();
  const todayStr = getISTDateString(referenceDate, timeZone);

  let startDateStr = todayStr;
  let endDateStr = todayStr;

  switch (normalizedRange) {
    case 'today':
      startDateStr = todayStr;
      endDateStr = todayStr;
      break;

    case 'yesterday': {
      const yestStr = shiftDateString(todayStr, -1);
      startDateStr = yestStr;
      endDateStr = yestStr;
      break;
    }

    case '7d':
    case 'last7days':
      startDateStr = shiftDateString(todayStr, -6);
      endDateStr = todayStr;
      break;

    case '30d':
    case 'last30days':
      startDateStr = shiftDateString(todayStr, -29);
      endDateStr = todayStr;
      break;

    case 'custom':
      if (customStart && customEnd) {
        // Enforce YYYY-MM-DD format
        const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
        if (dateRegex.test(customStart) && dateRegex.test(customEnd)) {
          startDateStr = customStart <= customEnd ? customStart : customEnd;
          endDateStr = customStart <= customEnd ? customEnd : customStart;
        } else {
          startDateStr = shiftDateString(todayStr, -29);
          endDateStr = todayStr;
        }
      } else if (customStart) {
        startDateStr = customStart;
        endDateStr = todayStr;
      } else {
        startDateStr = shiftDateString(todayStr, -29);
        endDateStr = todayStr;
      }
      break;

    default:
      startDateStr = shiftDateString(todayStr, -29);
      endDateStr = todayStr;
      break;
  }

  const startOfDay = new Date(`${startDateStr}T00:00:00.000+05:30`);
  const endOfDay = new Date(`${endDateStr}T23:59:59.999+05:30`);
  const days = generateDateSeries(startDateStr, endDateStr);

  return {
    range: normalizedRange,
    startDateStr,
    endDateStr,
    startISO: startOfDay.toISOString(),
    endISO: endOfDay.toISOString(),
    days,
    timeZone,
  };
}

/**
 * Determines whether a date falls between startISO and endISO inclusive.
 *
 * @param {string|Date} dateInput
 * @param {string} startISO
 * @param {string} endISO
 * @returns {boolean}
 */
function isDateInRange(dateInput, startISO, endISO) {
  if (!dateInput) return false;
  try {
    let targetDate;
    if (typeof dateInput === 'string' || typeof dateInput === 'number') {
      targetDate = new Date(dateInput);
    } else if (dateInput instanceof Date) {
      targetDate = dateInput;
    } else if (dateInput && typeof dateInput.toDate === 'function') {
      targetDate = dateInput.toDate();
    } else {
      targetDate = new Date(dateInput);
    }

    if (isNaN(targetDate.getTime())) return false;
    const targetISO = targetDate.toISOString();
    return targetISO >= startISO && targetISO <= endISO;
  } catch {
    return false;
  }
}

module.exports = {
  DEFAULT_BUSINESS_TIMEZONE,
  getISTDateString,
  getTodayTimezoneRange,
  isDateInTodayRange,
  getDateRangeBoundaries,
  isDateInRange,
  generateDateSeries,
  shiftDateString,
};
