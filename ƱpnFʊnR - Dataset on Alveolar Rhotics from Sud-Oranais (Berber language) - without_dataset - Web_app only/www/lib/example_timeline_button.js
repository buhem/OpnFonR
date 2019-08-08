var timeZone = "Europe/Paris";
var locale = "fr";
 
$(function() {
    document.getElementById("imgLoad").style.display = "none";
    document.getElementById("main-div").style.display = "block";
    timelineVis();
});

function timelineVis() {
    var array = getData();
    $("#puce-showHideAllGroups").removeClass("puce-triangle-right").addClass("puce-triangle-down");

    var values = array.filter(function(el) {
        return el[2] !== null
    });

    document.getElementById("spanSumEvents").innerHTML = values.length;
    var container = document.getElementById("timeline-vis");
    var types = ["box", "point", "range", "background"];
    var archis = values.map(function(el) {
        return el[3]
    }).filter(function(elem, i, array) {
        return array.indexOf(elem) === i
    });
    var groups = new vis.DataSet,
        items = new vis.DataSet,
        groupId = 1E3,
        globalDelta = 0;
    for (var g = 0, lg = archis.length; g < lg; g++) {
        var nested = [],
            count = 0,
            groupDelta = 0,
            statut, itemContent, tooltip, hrsEffectuees, className, visibleFramTemplate, diff, delta, classDelta, percent;
        for (var k in values) {
            var start = moment(values[k][13]).format("DD/MM/YYYY"),
                end = moment(values[k][14]).format("DD/MM/YYYY"),
                groupDates;
            values[k][7] && values[k][8] && values[k][7] !== undefined && values[k][8] !== undefined ? diff = (values[k][7] - values[k][8]) / values[k][7] : diff = 0;
            if (values[k][0] &&
                values[k][0] !== "undefined" && values[k][0] === "en cours") className = "default";
            if (values[k][0] && values[k][0] !== "undefined" && values[k][0] === "pr\u00e9vu") className = "prevu";
            if (values[k][0] && values[k][0] !== "undefined" && values[k][0] === "termin\u00e9") className = "termine";
            if (values[k][0] && values[k][1] && values[k][1] === "PAUSE") {
                statut = '<span class="glyphicon glyphicon-exclamation-sign" ></span> ' + values[k][1];
                className = "pause"
            } else statut = values[k][0];
            values[k][6] ? hrsEffectuees = parseInt(values[k][6], 10) : hrsEffectuees = 0;
            if (values[k][5] && values[k][6]) delta = parseInt(values[k][5], 10) - parseInt(values[k][6], 10);
            else {
                delta = parseInt(values[k][5], 10);
                values[k][6] = 0
            }
            if (values[k][0] === "en cours" || values[k][0] === "termin\u00e9") {
                delta >= 0 ? classDelta = "spanDeltaGreen" : classDelta = "spanDeltaRed";
                tooltip = values[k][2] + "<br>du " + start + " au " + end + "<br>pr\u00e9visionnel : " + values[k][5] + "hrs" + "<br>effectu\u00e9 : " + hrsEffectuees + "hrs" + ' <span class="' + classDelta + '">&Delta;' + delta + "</span>"
            } else tooltip = values[k][2] + "<br>du " + start +
                " au " + end + "<br>pr\u00e9visionnel : " + values[k][5] + "hrs";
            if (values[k][11] && values[k][11] !== undefined) {
                percent = parseInt(values[k][11] * 100, 10) + "%";
                visibleFramTemplate = '<div id="' + groupId + '" class="progress-wrapper"><div class="progress"><label class="progress-label">' + percent + "<label></div></div>"
            } else visibleFramTemplate = 0;
            values[k][15] && values[k][15] !== undefined ? values[k][15] = values[k][15] : values[k][15] = 0;
            itemContent = parseInt(values[k][15], 10) + " salari\u00e9s" + " (" + statut + ")";
            if (archis[g] == values[k][3]) {
                delta >= 0 ? classDelta = "spanDeltaGreen" : classDelta = "spanDeltaRed";
                items.add({
                    id: groupId,
                    group: groupId,
                    content: itemContent,
                    statut: statut,
                    value: values[k][11],
                    percentage: percent,
                    diff: Math.round(diff * 100),
                    start: moment(values[k][13]).toDate(),
                    end: moment(values[k][14]).endOf("day").toDate(),
                    className: className,
                    title: tooltip,
                    visibleFramTemplate: visibleFramTemplate
                });
                if (isValidDate(moment(values[k][13]).toDate()) && isValidDate(moment(values[k][14]).endOf("day").toDate())) {
                    groupDates = [moment(values[k][13]).toDate(), moment(values[k][14]).endOf("day").toDate()]
                } else {
                    groupDates = [null, null];
                }
                groups.add({
                    id: groupId,
                    content: values[k][2] + ' <span class="' + classDelta + '">&Delta; ' + parseInt(delta, 10) + "</span>",
                    groupDates: groupDates
                });
                nested.push(groupId);
                count++;
                groupDelta += parseInt(delta, 10)
            }
            groupId++
        }
        groupDelta > 0 ? classDelta = "spanDeltaGreen" : classDelta = "spanDeltaRed";
        groups.add({
            id: g + 1,
            content: archis[g] + ' <span class="spanGroup">' + count + "</span>" + ' <span class="' + classDelta + '">&Delta; ' + Math.round(groupDelta) + "</span>",
            nestedGroups: nested,
            showNested: true
        });
        globalDelta += groupDelta
    }
    globalDelta > 0 ? classDelta = "spanDeltaGreen" : classDelta = "spanDeltaRed";
    var spanGlobalDelta = document.getElementById("spanGlobalDelta");
    spanGlobalDelta.innerHTML = "&Delta; " + Math.round(globalDelta);
    spanGlobalDelta.className += classDelta;
    archisLength = function() {
        return archis.length
    };
    var timelineHeight = Math.round($(window).height() * .85) + "px";
    var options = {
        zoomKey: "ctrlKey",
        verticalScroll: true,
        horizontalScroll: true,
        orientation: {
            axis: "both",
            item: "top"
        },
        groupOrder: "id",
        width: "100%",
        height: timelineHeight,
        stack: false,
        visibleFrameTemplate: function(item) {
            if (item.visibleFramTemplate) {
                $($("#" + item.id).children()).css("width", item.percentage);
                if (item.value === 1) $($("#" + item.id).children()).css({
                    color: "white",
                    background: "#B40404"
                });
                return item.visibleFramTemplate
            }
        },
        tooltip: {
            overflowMethod: "cap"
        }
    };

    
    hideGroupsPanel = function(button) {
        $(button).hide();
        $("#buttonShowGroups").fadeIn();
        $(".fa-outdent").removeClass("fa-outdent").addClass("fa-indent");
        $(".vis-panel.vis-left").css("width", "0px");
        $("#titleTimeline-vis").css("display",
            "none");
        groups.forEach(function(group) {
            groups.update({
                id: group.id,
                showNested: false
            })
        })
    };
    showGroupsPanel = function(button) {
        $(button).hide();
        $("#buttonHideGroups").fadeIn();
        $(".fa-indent").removeClass("fa-indent").addClass("fa-outdent");
        $(".vis-panel.vis-left").removeAttr("style");
        $("#titleTimeline-vis").removeAttr("style");
        groups.forEach(function(group) {
            if (group["id"] < archisLength() + 1) groups.update({
                id: group.id,
                showNested: false
            });
            else groups.update({
                id: group.id,
                visible: false
            })
        })
    };
    showHideAllGroups = function(button) {
        if (button.dataset.value == "allGroups-hidden") {
            groups.forEach(function(group) {
                groups.update({
                    id: group.id,
                    visible: true,
                    showNested: true
                })
            });
            button.dataset.value = "allGroups-visible";
            $("#puce-showHideAllGroups").removeClass("puce-triangle-right").addClass("puce-triangle-down");
            changeTitleAttr($("#puce-showHideAllGroups").hasClass("puce-triangle-down"));
        } else {
            groups.forEach(function(group) {
                if (group["id"] < archisLength()) groups.update({
                    id: group.id,
                    showNested: false
                });
                else groups.update({
                    id: group.id,
                    visible: false
                })
            });
            button.dataset.value = "allGroups-hidden";
            $("#puce-showHideAllGroups").removeClass("puce-triangle-down").addClass("puce-triangle-right");
            changeTitleAttr($("#puce-showHideAllGroups").hasClass("puce-triangle-down"));
        }
    };
    var timeline = new vis.Timeline(container);
    timeline.setOptions(options);
    timeline.setGroups(groups);
    timeline.setItems(items);

    timeline.on("click", function(properties, timeZone) {
        var itemDates = groups.get(properties.group).groupDates;
        if (properties.pageX < 250 && itemDates) {
            timeline.fit();
            if (itemDates && itemDates.length) {
                var itemDateStart = itemDates[0],
                    itemDateEnd = itemDates[1];
                if (itemDateStart && itemDateEnd) timeline.setWindow({
                    start: itemDateStart.valueOf() - 864E4,
                    end: itemDateEnd.valueOf() + 864E4
                })
            }
        }
    });

    document.getElementById("moveToDate").onclick =
        function() {
            var dateToMove = document.getElementById("inputDateToMove").value,
                itemCustomTime, endDateToMove;
            endDateToMove = moment(moment(dateToMove).valueOf() + 5184E5).format("YYYY-MM-DD");
            if (items.get(dateToMove)) itemCustomTime = items.get(dateToMove).id;
            if (dateToMove && !items.get(dateToMove)) {
                timeline.addCustomTime(moment(dateToMove).toISOString(), {
                    id: dateToMove
                });
                items.add({
                    id: dateToMove,
                    content: moment(dateToMove).format("DD MMM"),
                    start: moment(dateToMove).toISOString(),
                    end: moment(moment(endDateToMove).endOf("day")).toISOString(),
                    type: "background"
                });
                timeline.setWindow(moment(dateToMove).toISOString(), moment(moment(endDateToMove).endOf("day")).toISOString(), {
                    animation: {
                        duration: 1E3,
                        easingFunction: "linear"
                    }
                });
                showAllGroups(dateToMove, endDateToMove)
            } else if (dateToMove && dateToMove === itemCustomTime) {
                timeline.setWindow(moment(dateToMove).toISOString(), moment(moment(endDateToMove).endOf("day")).toISOString(), {
                    animation: {
                        duration: 1E3,
                        easingFunction: "linear"
                    }
                });
                showAllGroups(dateToMove, endDateToMove)
            }
        };
    document.getElementById("globalView").onclick =
        function() {
            var groupsVisible = [],
                itemsVisible = [];
            groups.forEach(function(group) {
                if (group.id >= 1E3 && group.visible === true) groupsVisible.push(group.id)
            });
            items.forEach(function(item) {
                if (groupsVisible.indexOf(item.group) >= 0) itemsVisible.push(item.id)
            });
            timeline.focus(itemsVisible)
        };

    function showAllGroups(dateToMove, endDateToMove) {
        groups.forEach(function(group) {
            if (group.id >= 1E3 && group.groupDates && group.groupDates.length) {
                var startDateGroup = group.groupDates[0],
                    endDateGroup = group.groupDates[1];
                if (!(endDateGroup <=
                        moment(dateToMove) || startDateGroup >= moment(endDateToMove))) groups.update({
                    id: group.id,
                    visible: true,
                    showNested: true
                });
                else groups.update({
                    id: group.id,
                    visible: false
                })
            }
        })
    }

    function move(percentage) {
        var range = timeline.getWindow();
        var interval = range.end - range.start;
        timeline.setWindow({
            start: range.start.valueOf() - interval * percentage,
            end: range.end.valueOf() - interval * percentage
        })
    }
    document.getElementById("zoomIn").onclick = function() {
        timeline.zoomIn(.5)
    };
    document.getElementById("zoomOut").onclick = function() {
        timeline.zoomOut(.5)
    };
    document.getElementById("moveLeft").onclick = function() {
        move(.2)
    };
    document.getElementById("moveRight").onclick = function() {
        move(-.2)
    }

    $(function() {
        timeline.redraw();
        changeTitleAttr($("#puce-showHideAllGroups").hasClass("puce-triangle-down"))
    });
} // fin de timeline


function changeTitleAttr(flag) {
    console.log($("#puce-showHideAllGroups").hasClass("puce-triangle-down"));
    if (flag) {
        document.getElementById('allGroups-div').title = 'collapse all';
    } else {
        document.getElementById('allGroups-div').title = 'expand all';
    }
}

// source : http://stackoverflow.com/questions/1353684/detecting-an-invalid-date-date-instance-in-javascript
function isValidDate(d) {
    if (Object.prototype.toString.call(d) === "[object Date]") {
        // it is a date
        if (isNaN(d.valueOf())) {
            // d.getTimes() could also work
            return false;
        } else {
            return true;
        }
    } else {
        return false;
    }
}

/**
 * Date picker jQuery
 */
$(function() {
    $("#inputDateToMove").datepicker();
    $("#inputDateToMove").datepicker("setDate", moment().format("YYYY-MM-DD"));
});

$.datepicker.setDefaults({
    dateFormat: "yy-mm-dd",
    changeYear: true,
    showWeek: true,
    weekHeader: weekHeader(),
    monthNames: monthNames(),
    dayNamesMin: dayNamesMin(),
    firstDay: 1
});

function dayNamesMin() {
    if (locale === "fr") {
        return ["Di", "Lu", "Ma", "Me", "Je", "Ve", "Sa"];
    } else {
        return ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"];
    }
}

function monthNames() {
    if (locale === "fr") {
        return [
            "Janvier",
            "Février",
            "Mars",
            "Avril",
            "Mai",
            "Juin",
            "Juillet",
            "Août",
            "Septembre",
            "Octobre",
            "Novembre",
            "Decembre"
        ];
    } else {
        return [
            "January",
            "February",
            "March",
            "April",
            "May",
            "June",
            "July",
            "August",
            "September",
            "October",
            "November",
            "December"
        ];
    }
}

function weekHeader() {
    if (locale === "fr") {
        return ["Sem"];
    } else {
        return ["Wk"];
    }
}
   