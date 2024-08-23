import React, { useEffect, useState } from "react";

import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ReferenceLine,
} from "recharts";

// "Aug 18", "2022" => "August 18, 2022"
// "Start of Season Finals 2024" => "Start of Season Finals 2024"
function formatDateString(dateStr, year) {
  const date = new Date(`${dateStr} ${year}`);
  if (isNaN(date)) {
    return dateStr;
  }

  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });
}

export const Chart = ({ data }) => {  
  const lineChartData = data.data;
  const teamData = data.teams;
  const matchData = data.matches;
  const year = data.year;

  const [selectedDate, setSeletedDate] = useState(
    matchData[matchData.length - 1].date
  );
  // Set default so chart doesn't rerender on first hover
  const [hoveredDate, setHoveredDate] = useState(
    matchData[matchData.length - 1].date
  );

  function customToolTip(props) {
    return (
      <div>
        <div className="text-2xl text-center">{props.label}</div>
        <ul className="my-2 mx-4">
          {matchData
            .filter((match) => match.date == props.label)
            .map((datum) => {
              return renderMatch(datum);
            })}
        </ul>
      </div>
    );
  }

  function renderEloChange(changeAmount) {
    if (changeAmount < 0) {
      return <div className={"text-red-600"}>{changeAmount}</div>;
    } else {
      return <div className={"text-green-600"}>{`+ ${changeAmount}`}</div>;
    }
  }

  function renderMatch(match) {
    let score = `${match.opponent1_score} - ${match.opponent2_score}`;

    return (
      <li key={match.id} className="flex m-2 bg-purple-popout rounded border border-green-accent">
        <div className="mx-3 my-2 flex flex-col items-center">
          <div
            className="text-2xl"
            style={{ borderBottom: `2px solid ${match.opponent1.color}` }}
          >
            {match.opponent1.acronym}
          </div>
          <div className="flex flex-col items-end">
            <div>{match.opponent1_elo}</div>
            {renderEloChange(match.opponent1_elo_change)}
          </div>
        </div>
        <div className="text-lg mt-4">{score}</div>
        <div className="mx-3 my-2 flex flex-col items-center">
          <div
            className="text-2xl"
            style={{ borderBottom: `2px solid ${match.opponent2.color}` }}
          >
            {match.opponent2.acronym}
          </div>
          <div className="flex flex-col items-end">
            <div>{match.opponent2_elo}</div>
            {renderEloChange(match.opponent2_elo_change)}
          </div>
        </div>
      </li>
    );
  }

  function renderChart() {
    return (
      <LineChart
        width={1100}
        height={800}
        data={lineChartData}
        onClick={(chart) => setSeletedDate(chart.activeLabel)}
        onMouseMove={(state) => {
          if (state.activeLabel) {
            setHoveredDate(state.activeLabel);
          }
        }}
      >
        <CartesianGrid />
        {hoveredDate && (
          <ReferenceLine
            x={hoveredDate}
            stroke="#aaa"
            strokeWidth={2}
          />
        )}
        {selectedDate && (
          <ReferenceLine
            x={selectedDate}
            stroke="#00D17A"
            strokeWidth={2}
          />
        )}
        <XAxis dataKey="name" padding={{ left: 30, right: 30 }} />
        <YAxis type="number" domain={["dataMin - 50", "dataMax + 50"]} />
        <Tooltip content={customToolTip} />
        {teamData.map((team) => {
          return (
            <Line
              key={team.id}
              type="monotone"
              strokeWidth={2}
              dataKey={team.acronym}
              stroke={team.color}
            />
          );
        })}
      </LineChart>
    );
  }

  function renderList() {
    const dateData = lineChartData.filter((d) => d.name === selectedDate)[0];
    const teamElos = teamData.reduce((result, team) => {
      const teamObj = {
        name: team.name,
        elo: dateData[team.acronym],
        color: team.color,
      };
      result.push(teamObj);
      return result;
    }, []);
    const sortedTeamElos = teamElos.sort(
      (a, b) => b.elo - a.elo
    );

    return (
      <div className="ml-4 mr-2">
        <h2 
          className={"text-2xl mx-2 my-4 text-green-accent"}
        >{formatDateString(selectedDate, year)}</h2>
        <ul>
          {sortedTeamElos.map((team) => {
            return (
              <li 
                key={team.acronym}
                className="m-2 flex items-center"
              >
                <div
                  className="w-4 h-4 rounded-full mr-2"
                  style={{ backgroundColor: team.color }}
                />
                <span>{team.name}: {team.elo}</span>
              </li>
            );
          })}
        </ul>
      </div>
    );
  }

  return (
    <div class="flex flex-row">
      {renderChart()}
      {renderList()}
    </div>
  );
}

// This is so dumb
// https://github.com/shakacode/react_on_rails/issues/1198#issuecomment-593486485
export default props => <Chart {...props} />;