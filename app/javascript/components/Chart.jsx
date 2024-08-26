import React, { useEffect, useState } from "react";

import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ReferenceLine,
  ResponsiveContainer
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

  const lastDate = lineChartData[lineChartData.length - 1].name;
  const [selectedDate, setSeletedDate] = useState(
    lastDate
  );
  // Set default so chart doesn't rerender on first hover
  const [hoveredDate, setHoveredDate] = useState(
    lastDate
  );

  const dateData = lineChartData.filter((d) => d.name === lastDate)[0];
  const bestTeam = sortedTeamElos(dateData)[0];
  const [selectedTeamIds, setSelectedTeamIds] = useState(
    [bestTeam.id]
  )
  function selectTeam(teamId) {
    if (selectedTeamIds.includes(teamId)) {
      setSelectedTeamIds(selectedTeamIds.filter((id) => id !== teamId));
    } else {
      setSelectedTeamIds([...selectedTeamIds, teamId]);
    }
  }
  function isTeamSelected(teamId) {
    if (selectedTeamIds.length === 0) {
      return true;
    } else {
      return selectedTeamIds.includes(teamId);
    }
  }

  const [fontSize, setFontSize] = useState(14);
  const [aspectRatio, setAspectRatio] = useState(5 / 3); // Default aspect ratio
  const [chartLeft, setChartLeft] = useState(-12);

  useEffect(() => {
    const handleResize = () => {
      const width = window.innerWidth;
      if (width < 640) {
        setFontSize(10);
        setAspectRatio(3 / 3);
        setChartLeft(-20);
      } else if (width < 1024) {
        setFontSize(12);
        setAspectRatio(4 / 3);
        setChartLeft(-12);
      } else {
        setFontSize(14);
        setAspectRatio(5 / 3);
        setChartLeft(-4);
      }
    };

    window.addEventListener('resize', handleResize);
    handleResize();

    return () => window.removeEventListener('resize', handleResize);
  }, []);

  function customToolTip(props) {
    return (
      <div>
        <div className="text-base sm:text-lg md:text-xl text-center">{props.label}</div>
        <ul>
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
      <li key={match.id} className="flex mt-1 mb-2 bg-purple-popout rounded border border-green-accent">
        {renderMatchOpponent(match.opponent1.color, match.opponent1.acronym, match.opponent1_elo, match.opponent1_elo_change)}
        <div className="text-base lg:text-lg mt-4">{score}</div>
        {renderMatchOpponent(match.opponent2.color, match.opponent2.acronym, match.opponent2_elo, match.opponent2_elo_change)}
      </li>
    );
  }

  function renderMatchOpponent(color, acronym, elo, eloChange) {
    return (
      <div className="mx-2 my-1 flex flex-col items-center">
        <div
          className="text-base lg:text-lg "
          style={{ borderBottom: `2px solid ${color}` }}
        >
          {acronym}
        </div>
        <div className="flex flex-col items-end text-sm lg:text-md">
          <div>{elo}</div>
          {renderEloChange(eloChange)}
        </div>
      </div>
    )
  }

  function renderChart() {
    return (
      <ResponsiveContainer width="100%" aspect={aspectRatio}>
        <LineChart
          data={lineChartData}
          margin={{ left: chartLeft, right: 6 }}
          onClick={(chart) => {
            if (chart.activeLabel) {
              setSeletedDate(chart.activeLabel)
            }
          }}
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
          <XAxis 
            dataKey="name"
            tick={{ fontSize: fontSize}}
            tickFormatter={(value) => `${value}`}
          />
          <YAxis 
            type="number" 
            domain={["dataMin - 50", "dataMax + 50"]} 
            tick={{ fontSize: fontSize}}
            tickFormatter={(value) => `${value}`}
            padding={{ left: 0 }}
          />
          <Tooltip content={customToolTip} />
          {teamData.map((team) => {
            return (
              <React.Fragment key={team.id}>
                <Line
                  type="monotone"
                  strokeWidth={3}
                  dataKey={team.acronym}
                  stroke={isTeamSelected(team.id) ? team.color : "#777"}
                />
                <Line
                  strokeWidth={12}
                  stroke="transparent"
                  dataKey={team.acronym}
                  onClick={() => selectTeam(team.id)}
                  style={{ cursor: 'pointer' }}
                  dot={false}
                />
              </React.Fragment>
            );
          })}
        </LineChart>
      </ResponsiveContainer>
    );
  }

  function sortedTeamElos(dateData) {
    return teamData.reduce((result, team) => {
      const teamObj = {
        name: team.name,
        elo: dateData[team.acronym],
        color: team.color,
        id: team.id,
      };
      result.push(teamObj);
      return result;
    }, []).sort((a, b) => b.elo - a.elo);
  }

  function renderList() {
    const dateData = lineChartData.filter((d) => d.name === selectedDate)[0];
    const teamElos = sortedTeamElos(dateData);

    return (
      <div className="ml-1 md:ml-4 mr-2">
        <h2 
          className={"text-lg lg:text-xl mx-2 mb-2 mt-1 text-green-accent"}
        >{formatDateString(selectedDate, year)}</h2>
        <ul>
          {teamElos.map((team) => {
            return (
              <li 
                key={team.name}
                className="m-2 flex items-center cursor-pointer"
                onClick={() => selectTeam(team.id)}
              >
                <div
                  className="w-4 h-4 rounded-full mr-2 border-2"
                  style={{ backgroundColor: isTeamSelected(team.id) ? team.color : "transparent", borderColor: team.color }}
                />
                <span className="text-sm lg:text-base">{team.name}: {team.elo}</span>
              </li>
            );
          })}
        </ul>
        <button onClick={() => setSelectedTeamIds([])} className="text-sm lg:text-base underline">Clear Selections</button>
      </div>
    );
  }

  return (
    <div className="flex flex-col md:flex-row">
      {renderChart()}
      {renderList()}
    </div>
  );
}

// This is so dumb
// https://github.com/shakacode/react_on_rails/issues/1198#issuecomment-593486485
export default props => <Chart {...props} />;