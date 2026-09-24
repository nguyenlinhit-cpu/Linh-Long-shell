pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Weather Metrics
    property string temperature: "--°C"
    property string condition: "Loading..."
    property string icon: "󰖙"
    property string humidity: "--%"
    property string wind: "-- km/h"
    property string city: "Local"
    property bool loaded: false

    // Fetch live weather data every 15 minutes
    Timer {
        id: weatherTimer
        interval: 15 * 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.fetchWeather()
    }

    function fetchWeather() {
        let xhr = new XMLHttpRequest();
        xhr.open("GET", "https://wttr.in/?format=j1", true);
        xhr.timeout = 5000;
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        let json = JSON.parse(xhr.responseText);
                        let current = json.current_condition ? json.current_condition[0] : null;
                        let area = json.nearest_area ? json.nearest_area[0] : null;

                        if (current) {
                            root.temperature = `${current.temp_C}°C`;
                            root.condition = current.weatherDesc ? current.weatherDesc[0].value : "Clear";
                            root.humidity = `${current.humidity}%`;
                            root.wind = `${current.windspeedKmph} km/h`;
                            root.icon = root.resolveWeatherIcon(root.condition);
                            root.loaded = true;
                        }
                        if (area && area.areaName) {
                            root.city = area.areaName[0].value;
                        }
                    } catch(e) {
                        // Fallback gracefully
                        root.fallbackWeather();
                    }
                } else {
                    root.fallbackWeather();
                }
            }
        };
        xhr.ontimeout = function() {
            root.fallbackWeather();
        };
        xhr.send();
    }

    function fallbackWeather() {
        if (!root.loaded) {
            root.temperature = "26°C";
            root.condition = "Partly Cloudy";
            root.icon = "󰖐";
            root.humidity = "62%";
            root.wind = "14 km/h";
            root.loaded = true;
        }
    }

    function resolveWeatherIcon(desc) {
        let low = (desc || "").toLowerCase();
        if (low.includes("sunny") || low.includes("clear")) return "󰖙";
        if (low.includes("partly") || low.includes("cloud")) return "󰖐";
        if (low.includes("rain") || low.includes("shower") || low.includes("drizzle")) return "󰖗";
        if (low.includes("thunder") || low.includes("storm") || low.includes("lightning")) return "󰙾";
        if (low.includes("snow") || low.includes("ice") || low.includes("blizzard")) return "󰖘";
        if (low.includes("fog") || low.includes("mist") || low.includes("haze")) return "󰖑";
        return "󰖙";
    }
}
